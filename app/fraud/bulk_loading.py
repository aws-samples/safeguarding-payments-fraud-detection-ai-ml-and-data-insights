import psycopg2
from pgvector.psycopg2 import register_vector
import boto3
from botocore.exceptions import ClientError
import json
import os
from dotenv import load_dotenv


#client = boto3.client('secretsmanager')

def get_secret():
    secret_name = "rdspg-vector-secret"
    region_name = "us-east-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        raise e

    secret = get_secret_value_response['SecretString']
    return secret

def main():

  #database_secrets = json.loads(get_secret())

  #dbhost = database_secrets['host']
  #dbport = database_secrets['port']
  #dbuser = database_secrets['username']
  #dbpass = database_secrets['password']

  dbconn = psycopg2.connect(host=dbhost, port=dbport, user=dbuser, password=dbpass, connect_timeout=10)
  dbconn.set_session(autocommit=True) 
  # enable extension
  cur = dbconn.cursor()
  cur.execute("CREATE EXTENSION IF NOT EXISTS vector;")
  register_vector(dbconn)

  # create table
  cur.execute("DROP TABLE IF EXISTS fraud_payments;")
  cur.execute("""CREATE TABLE IF NOT EXISTS fraud_payments(
              id bigserial primary key,
              column1 text,
              column2 text,
              column3 text,
              embeddings vector(384)
  );""")

  for x in data:
    cur.execute("""INSERT INTO fraud_payments (column1, column2, column3, embeddings)
	  VALUES (%s, %s, %s, %s);""",
	  (' '.join(x.get('descriptions', [])), x.get('url'), x.get('split'), x.get('embeddings') ))

  cur.execute("""CREATE INDEX ON products
            USING ivfflat (descriptions_embeddings vector_l2_ops) WITH (lists = 100);""")
  cur.execute("VACUUM ANALYZE products;")
  cur.close()
  dbconn.close()

if __name__ == '__main__':
    #secret = json.loads(get_secret())

    load_dotenv()
    dbname=os.environ.get('DBNAME')
    dbhost=os.environ.get('DBHOST')
    dbuser=os.environ.get('DBUSER')
    dbpass=os.environ.get('DBPASS')
    dbport=os.environ.get('DBPORT')
    main()