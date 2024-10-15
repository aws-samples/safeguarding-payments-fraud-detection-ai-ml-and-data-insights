import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sentence_transformers import SentenceTransformer
from timeit import default_timer as timer
import datetime

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.decomposition import PCA

import psycopg2
from pgvector.psycopg2 import register_vector

from kubernetes import client, config

from dotenv import load_dotenv
import os
import boto3
from botocore.exceptions import ClientError



def load_kubernetes_config():
    try:
        # Try to load in-cluster configuration
        config.load_incluster_config()
    except config.ConfigException:
        # If that fails, try to load kubeconfig file
        try:
            config.load_kube_config()
        except config.ConfigException:
            print("Failed to load Kubernetes configuration")
            return False
    return True

def get_namespace(prefix):
    if not load_kubernetes_config():
        return None

    v1 = client.CoreV1Api()
    try:
        namespaces = v1.list_namespace()
        for ns in namespaces.items:
            if ns.metadata.name.startswith(prefix):
                return ns.metadata.name
    except client.ApiException as e:
        print(f"Error listing namespaces: {e}")
    return None

# Function to get values from ConfigMap
def get_config_map_values(config_map_name = "config-map"):
    if not load_kubernetes_config():
        return None

    v1 = client.CoreV1Api()
    namespace = get_namespace("spf-app-anomaly-detector")

    if not namespace:
        print("Failed to find namespace")
        return None

    try:
        config_map = v1.read_namespaced_config_map(config_map_name, namespace)
        return config_map.data
    except client.ApiException as e:
        print(f"Error reading ConfigMap: {e}")
        return None


def convert_file_to_pd(file_path):
    try:
        df = pd.read_csv(file_path)
        return df
    except FileNotFoundError:
        print("Error: File not found")
        return

def initialize_s3_client():
    try:
        s3_client = boto3.client('s3')
        return s3_client
    except ClientError as e:
        print(f"Error: {e}")
        raise


def list_s3_files(s3_client, s3_bucket_name, s3_path_payment):
    try:
        #s3_client = boto3.client('s3')
        response = s3_client.list_objects_v2(
            Bucket=s3_bucket_name,
            Prefix=s3_path_payment,
            MaxKeys=100
        )
    except ClientError as e:
        error_code = e.response['Error']['Code']
        if error_code == 'NoSuchBucket':
            print(f"Error: Bucket '{s3_bucket_name}' does not exist.")
        else:
            print(f"Error: {e}")
        raise

    if response.get("KeyCount")>0:
        s3_files = response.get("Contents")
    return s3_files

def download_s3_file(s3_client, s3_file, local_file_path, s3_bucket_name):
    # get local folder path
    local_folder_path = os.path.split(local_file_path)[0]
    print(local_folder_path)
    # create local folder if not exists
    os.makedirs(local_folder_path, exist_ok=True)
    # download file from s3 to local
    s3_client.download_file(s3_bucket_name, s3_file, local_file_path)

def upload_s3_file(s3_client, s3_bucket_name, local_file_path, s3_file):
    s3_client.upload_file(local_file_path, s3_bucket_name, s3_file)
    print(f"File '{local_file_path}' uploaded to S3 bucket '{s3_bucket_name}'")

def create_embeddings(df):
    # Separate numerical, categorical, text and timestamps features
    numerical_features   = ["billing_zip", "billing_latitude", "billing_longitude", "order_price"]
    categorical_features = ["billing_state", "billing_country", "product_category"]
    textual_features     = ["customer_name", "billing_city", "billing_street", "customer_email", "billing_phone", "ip_address"] 
    timestamp_features   = ["EVENT_TIMESTAMP", "LABEL_TIMESTAMP"]


    # Feature scaling for numerical values
    scaler = StandardScaler()
    df[numerical_features] = scaler.fit_transform(df[numerical_features])

    # One-hot encoding for categorical features
    encoded_categorical_features = pd.get_dummies(df[categorical_features], drop_first=True)

    # Preprocess timestamp features
    for col in timestamp_features:
        df[col] = pd.to_datetime(df[col])
        df[col + "_year"] =df[col].dt.year
        df[col + "_month"] =df[col].dt.month
        df[col + "_day"] =df[col].dt.day
        df[col + "_hour"] =df[col].dt.hour
        df[col + "_minute"] =df[col].dt.minute
        df[col + "_second"] =df[col].dt.second

    new_timestamp_features = [col for col in df.columns if col.startswith("EVENT_TIMESTAMP_") or col.startswith("LABEL_TIMESTAMP_")]

    # Combine numerical, categorical and timestamp features
    combined_features = pd.concat([df[numerical_features], encoded_categorical_features, df[new_timestamp_features]], axis=1)
    print(combined_features.head())

    # Generate embedings for textual features
    print("create embeddings")
    model = SentenceTransformer("sentence-transformers/all-mpnet-base-v2")
    text_embeddings = model.encode(df[textual_features].fillna("").sum(axis=1).tolist())
    print("End embeddings")


    # Concatenate embeddings
    embeddings = np.concatenate([combined_features.values, text_embeddings], axis=1)
    #embeddings = np.concatenate([combined_features.values], axis=1)

    print(embeddings.shape)
    return embeddings

def create_embeddings_pca(df):
    numerical_features   = ["billing_zip", "billing_latitude", "billing_longitude", "order_price"]
    categorical_features = ["billing_state", "billing_country", "product_category"]
    textual_features     = ["customer_name", "billing_city", "billing_street", "customer_email", "billing_phone", "ip_address"] 
    timestamp_features   = ["EVENT_TIMESTAMP", "LABEL_TIMESTAMP"]


    # Preprocess timestamp features
    for col in timestamp_features:
        df[col] = pd.to_datetime(df[col])
        df[col + "_year"] =df[col].dt.year
        df[col + "_month"] =df[col].dt.month
        df[col + "_day"] =df[col].dt.day
        df[col + "_hour"] =df[col].dt.hour
        df[col + "_minute"] =df[col].dt.minute
        df[col + "_second"] =df[col].dt.second

    # Feature scaling for numerical features
    scaler = StandardScaler()
    df[numerical_features] = scaler.fit_transform(df[numerical_features])

    # PCA for dimensionality reduction
    pca = PCA(n_components=2)
    pca_components = pca.fit_transform(df[numerical_features])

    # One-hot encoding for categorical features
    encoded_categorical_features = pd.get_dummies(df[categorical_features], drop_first=True)

    # Combine features
    combined_features = pd.concat(
        [pd.DataFrame(pca_components), encoded_categorical_features], axis=1
    )

    # Generate text embeddings
    model = SentenceTransformer("sentence-transformers/all-mpnet-base-v2")
    text_embeddings = model.encode(df[textual_features].fillna("").sum(axis=1).tolist())

    # Combine numerical and categorical embeddings
    embeddings = np.concatenate([combined_features.values, text_embeddings], axis=1)
   
    print(df.head())

    print("Embeddings Shape:", embeddings.shape)
    print("Embbeddings:")
    print(embeddings[:5,:])
    return embeddings

def get_service_ip():
    # Load Kubernetes configuration
    #config.load_kube_config()
    config.load_incluster_config()

    # Create a Kubernetes API client
    api_client = client.CoreV1Api()

    # Get the service IP address
    service_name = os.environ.get('SERVICE_NAME')
    name_space = os.environ.get('NAMESPACE')
    service = api_client.read_namespaced_service(name=service_name, namespace=name_space)
    service_ip = service.spec.cluster_ip

    return service_ip

def connect_to_postgres(dbname, dbuser, dbpass, service_name, service_port, namespace):
    # Connect to PostgreSQL database
    #DBHOST = get_service_ip()
    try:
        dbconn = psycopg2.connect(
            host = service_name + "." + namespace,
            port = service_port,
            database = dbname,
            user = dbuser,        
            password = dbpass,
        )
        return dbconn
    except (Exception, psycopg2.DatabaseError) as error:
        print("Error while connecting to PostgreSQL", error)
        raise

def get_date_from_database():
    dbconn = connect_to_postgres()
    cursor = dbconn.cursor()
    cursor.execute("SELECT * FROM processing_date")
    results = cursor.fetchall()
    date = results[0][0]
    cursor.close()
    dbconn.close()
    return date

def is_fraud_payment(embeddings, dbname, dbuser, dbpass, service_name, service_port, namespace):
    dbconn = connect_to_postgres(dbname, dbuser, dbpass, service_name, service_port, namespace)
    register_vector(dbconn)
    cursor = dbconn.cursor()
    distance = []
    for embedding in embeddings:
        cursor.execute('SELECT MAX(1 - (embedding <=> %s)) FROM payment_data', (embedding,))
        results = cursor.fetchall()
        distance.append([result[0] for result in results])

    cursor.close()
    dbconn.close()

def get_distance(embedding):
    dbconn = connect_to_postgres()
    register_vector(dbconn)
    cursor = dbconn.cursor()
    cursor.execute('SELECT MAX(1 - (embedding <=> %s)) FROM payment_data', (embedding,))
    results = cursor.fetchall()
    distance = [result[0] for result in results]
    cursor.close()
    dbconn.close()
    return distance

def insert_to_postgres(embeddings):
    dbconn = connect_to_postgres()

    # Register pgvector connection
    register_vector(dbconn)
    # Create a cursor object
    cursor = dbconn.cursor()
    # Insert values
    # print("Insert to payment table")
    embeddings = np.array(embeddings, dtype=float)
    file_name ="./data/" + "foo.csv"
    np.savetxt(file_name, embeddings, delimiter=",")

    for embedding in embeddings:
        cursor.execute("INSERT INTO payment_data (embedding) VALUES (%s)", (embedding, ))
        dbconn.commit()
   
    # Close the cursor and connection
    cursor.close()
    dbconn.close()


def main():

    load_dotenv()

    # Get values from ConfigMap
    config_map_values = get_config_map_values()

    # Get the values from the ConfigMap
    dbname = config_map_values.get("DBNAME")
    dbuser = config_map_values.get("DBUSER")
    dbpass = config_map_values.get("DBPASS")
    service_port = config_map_values.get("SERVICE_PORT")
    service_name = config_map_values.get("SERVICE_NAME")
    namespace = config_map_values.get("NAMESPACE")
    s3_bucket_name = config_map_values.get("S3_BUCKET_NAME")
    s3_path_payment = config_map_values.get("S3_PATH_PAYMENT")
    s3_path_model = config_map_values.get("S3_PATH_MODEL")


    # Local path
    data_folder_path = "./data/"
    
    # Initialize the s3 client
    s3_client = initialize_s3_client()
    # get S3 file details
    s3_files = list_s3_files(s3_client=s3_client, s3_bucket_name=s3_bucket_name, s3_path_payment=s3_path_payment)
    
    # get date from database
    #processing_date = get_date_from_database()
   
    # get csv file names only and last modified must be greater than the date from database
    csv_s3_keys = []
    for s3_file in s3_files:
        #if s3_file["Key"].endswith(".csv") and s3_file["LastModified"].date() > processing_date:
        if s3_file["Key"].endswith(".csv"):    
            csv_s3_keys.append(s3_file["Key"])

    # for every S3 file
    for csv_s3_key in csv_s3_keys:
        # set local file path
        local_file_path = os.path.join(data_folder_path, csv_s3_key)
        # download s3 file to local file path
        download_s3_file(s3_client, csv_s3_key, local_file_path, s3_bucket_name)
        # Convert file to pandas dataframe
        df = convert_file_to_pd(local_file_path)
        if df is not None:
            embeddings = create_embeddings(df)
            embeddings = np.array(embeddings, dtype=float)
            is_fraud_payment(embeddings, dbname, dbuser, dbpass, service_name, service_port, namespace)
            csv_s3_key = csv_s3_key.replace(s3_path_payment, s3_path_model)
            upload_s3_file(s3_client, s3_bucket_name,local_file_path, csv_s3_key)

    
if __name__ == '__main__':
    start = timer()
    main()
    end = timer()
    print(end - start)
