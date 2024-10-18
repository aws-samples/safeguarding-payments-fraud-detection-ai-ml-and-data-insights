import sys
import pandas as pd
import numpy as np
from pgvector.psycopg import register_vector
import psycopg
from dotenv import load_dotenv
import os
import boto3
from botocore.exceptions import ClientError
import json
from kubernetes import client, config


def create_database():
    conn = connect_to_postgres("postgres")
    cur = conn.cursor()

    # Check if the database exists
    cur.execute("SELECT 1 FROM pg_database WHERE datname = 'transactions';")

    # If the database doesn't exist, create it
    if cur.fetchone() is None:
        print("Database 'transactions' does not exist. Creating it...")
        cur.execute("CREATE DATABASE transactions;")

def create_tables():
    secret = get_secrets()
    DBNAME = secret["SPF_DOCKERFILE_DBNAME"]

    conn = connect_to_postgres(DBNAME)
    cur = conn.cursor()
    cur.execute("CREATE EXTENSION IF NOT EXISTS vector;")
    cur.execute("CREATE TABLE IF NOT EXISTS transaction (id BIGSERIAL PRIMARY KEY, embedding vector(847));")
    cur.execute("CREATE TABLE IF NOT EXISTS transaction_anomalies (id BIGSERIAL PRIMARY KEY, embedding vector(847));")


def insert_to_postgres(embeddings, table_name):
    # connect to postgres
    secret = get_secrets()
    DBNAME = secret["SPF_DOCKERFILE_DBNAME"]
    conn = connect_to_postgres(DBNAME)
    register_vector(conn)
    print(f'Loading {len(embeddings)} rows')
    cur = conn.cursor()
    # build the copy stament using table_name
    copy_statement = f"COPY {table_name} (embedding) FROM STDIN WITH (FORMAT BINARY)"

    with cur.copy(copy_statement) as copy:
        copy.set_types(['vector'])

        for i, embedding in enumerate(embeddings):
            # show progress
            if i % 10000 == 0:
                print('.', end='', flush=True)

            copy.write_row([embedding])

            # flush data
            while conn.pgconn.flush() == 1:
                pass
    print('\nSuccess!')

def get_secrets(secret_prefix="spf-secrets-deploy"): # nosec B107
    # Create a Secrets Manager client
    region_name = os.environ.get('AWS_REGION')
    client = boto3.client('secretsmanager', region_name=region_name)

    # List all secrets
    response = client.list_secrets(MaxResults=100)
    secret_list = response['SecretList']

    # Filter secrets that start with the given prefix
    matching_secrets = [secret for secret in secret_list if secret['Name'].startswith(secret_prefix)]
    
    # Check if any secrets were found
    if not matching_secrets:
        raise ValueError(f"No secret found with prefix: {secret_prefix}")
    
    # Get the full SecretId of the first matching secret
    full_secret_id = matching_secrets[0]['ARN']
    
    # Now use the full SecretId to get the secret value
    get_secret_value_response = client.get_secret_value(SecretId=full_secret_id)

    if 'SecretString' in get_secret_value_response:
        secret_string = get_secret_value_response['SecretString']
        secret_dict = json.loads(secret_string)
    else:
        # For binary secrets, decode them before using
        secret_dict = json.loads(get_secret_value_response['SecretBinary'].decode('utf-8'))

    return secret_dict

def connect_to_postgres(DBNAME):
    # Get secrets from aws secrets manager
    secret = get_secrets()

    # Get values from the secret
    DBUSER = secret["SPF_DOCKERFILE_DBUSER"]
    DBPASS = secret["SPF_DOCKERFILE_DBPASS"]
    DBPORT = secret["SPF_SERVICE_DBPORT"]
    DBSERVICE = secret["SPF_SERVICE_DBNAME"]
    DBNAMESPACE = secret["SPF_SERVICE_NAMESPACE"]

    # Determine the host based on the environment
    if "KUBERNETES_SERVICE_HOST" in os.environ:
        # We're inside a Kubernetes pod
        DBHOST = DBSERVICE + "." + DBNAMESPACE
    else:
        # We're outside the cluster, use the external access point
        DBHOST = secret["SPF_DOCKERFILE_DBHOST"]

    # Create the connection string
    conn_string = f"host={DBHOST} dbname={DBNAME} user={DBUSER} password={DBPASS} port={DBPORT}"

    # Attempt to connect
    try:
        conn = psycopg.connect(conn_string, autocommit=True)
        return conn
    except psycopg.Error as e:
        print(f"Unable to connect to the database: {e}")
        raise

def check_if_records_exist(conn, table_name):
    cur = conn.cursor()
    cur.execute(f"SELECT COUNT(*) FROM {table_name};")
    count = cur.fetchone()[0]
    return count > 0

def main():
    load_dotenv()

    secret = get_secrets()
    DBNAME = secret["SPF_DOCKERFILE_DBNAME"]

    database_existed = True
    try:
        # Attempt to connect to the database
        conn = connect_to_postgres(DBNAME)
    except psycopg.OperationalError as e:
        if "database" in str(e) and "does not exist" in str(e):
            print(f"Database {DBNAME} does not exist. Attempting to create it.")
            try:
                # Create database
                create_database()
                print(f"Database {DBNAME} created successfully.")

                # Attempt to connect again after creating the database
                conn = connect_to_postgres(DBNAME)
                database_existed = False
            except Exception as create_error:
                print(f"Error creating or connecting to the database: {create_error}")
                sys.exit(1)
        else:
            print(f"Error connecting to the database: {e}")
            sys.exit(1)

    try:
        if database_existed:
            if check_if_records_exist(conn, "transaction") or check_if_records_exist(conn, "transaction_anomalies"):
                print("Records already exist in the database. Skipping insertion.")
                return

        # Create tables
        create_tables()

        embeddings_anomalies_files = os.environ.get('EMBEDDINGS_ANOMALIES_FILES')
        embeddings_transactions_files = os.environ.get('EMBEDDINGS_TRANSACTIONS_FILES')

        embeddings_anomalies_files = embeddings_anomalies_files.split(',')
        embeddings_transactions_files = embeddings_transactions_files.split(',')

        for url in embeddings_anomalies_files:
            df = pd.read_csv(url)
            embeddings = df.to_numpy()
            insert_to_postgres(embeddings, "transaction_anomalies")

        for url in embeddings_transactions_files:
            df = pd.read_csv(url)
            embeddings = df.to_numpy()
            insert_to_postgres(embeddings, "transaction")

    except Exception as e:
        print(f"An error occurred during execution: {e}")
    finally:
        if conn:
            conn.close()

if __name__ == '__main__':
    main()
