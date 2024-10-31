"""
This script detects anomalies in payments data using several machine learning techniques.
It reads input data from S3 bucket and transforms into embeddings using Standard Scaler
and Sentence Transformer, then compares them to model data stored in PostgreSQL. Finally,
enriched dataset with cosine similarity as anomaly signal (between 0 and 1) is stored as
output data into S3 bucket.
"""

from asyncio import run
from timeit import default_timer
from os import path, makedirs
from concurrent.futures import ProcessPoolExecutor
from psycopg_pool import ConnectionPool
from boto3 import client as boto3_client
from pandas import get_dummies, to_datetime, concat, read_csv
from numpy import concatenate
from sklearn.preprocessing import StandardScaler
from sentence_transformers import SentenceTransformer
from kubernetes import client as k8s_client, config as k8s_config

def get_config_map_values(config_map_name = "config-map"):
    """
    Retrieves configuration values from a Kubernetes ConfigMap.
    """
    if not load_kubernetes_config():
        return None

    v1 = k8s_client.CoreV1Api()
    namespace = get_namespace("spf-app-anomaly-detector")

    if not namespace:
        print("Failed to find namespace")
        return None

    try:
        config_map = v1.read_namespaced_config_map(config_map_name, namespace)
        return config_map.data
    except k8s_client.ApiException as e:
        print(f"Error reading ConfigMap: {e}")
        return None

def load_kubernetes_config():
    """
    Attempts to load the Kubernetes configuration.
    """
    try:
        # Try to load in-cluster configuration
        k8s_config.load_incluster_config()
    except k8s_config.ConfigException:
        # If that fails, try to load kubeconfig file
        try:
            k8s_config.load_kube_config()
        except k8s_config.ConfigException:
            print("Failed to load Kubernetes configuration")
            return False
    return True

def get_namespace(prefix):
    """
    Retrieves the namespace based on the provided prefix.
    """
    if not load_kubernetes_config():
        return None

    v1 = k8s_client.CoreV1Api()
    try:
        namespaces = v1.list_namespace()
        for ns in namespaces.items:
            if ns.metadata.name.startswith(prefix):
                return ns.metadata.name
    except k8s_client.ApiException as e:
        print(f"Error listing namespaces: {e}")
    return None

def list_s3_files(s3_client, s3_bucket_name, s3_path_payment):
    """
    Lists all files in the specified S3 bucket and path.
    """
    # @todo: iterate through results over 100
    response = s3_client.list_objects_v2(
        Bucket=s3_bucket_name,
        Prefix=s3_path_payment,
        MaxKeys=100
    )

    if response.get("KeyCount") > 0:
        return response.get("Contents")

    return []

def download_s3_file(s3_client, s3_bucket_name, s3_file, local_file_path):
    """
    Downloads a file from an S3 bucket to a local path.
    """
    # get local folder path
    local_folder_path = path.split(local_file_path)[0]
    print(local_folder_path)
    # create local folder if not exists
    makedirs(local_folder_path, exist_ok=True)
    # download file from s3 to local
    s3_client.download_file(s3_bucket_name, s3_file, local_file_path)
    print(f"File '{local_file_path}' downloaded from s3 path '{s3_bucket_name}/{s3_file}'")

def upload_s3_file(s3_client, s3_bucket_name, local_file_path, s3_file):
    """
    Uploads a file to an S3 bucket.
    """
    s3_client.upload_file(local_file_path, s3_bucket_name, s3_file)
    print(f"File '{local_file_path}' uploaded to s3 path '{s3_bucket_name}/{s3_file}'")

def process_dataframe(df):
    """
    Pre-processes the input DataFrame for feature engineering and scaling.
    """
    # Separate numerical, categorical, text and timestamps features
    numerical_features = ["billing_zip", "billing_latitude", "billing_longitude", "order_price"]
    categorical_features = ["billing_state", "billing_country", "product_category"]
    textual_features = [
        "customer_name", "billing_city", "billing_street",
        "customer_email", "billing_phone", "ip_address"
    ]
    timestamp_features = ["EVENT_TIMESTAMP", "LABEL_TIMESTAMP"]

    # Feature scaling for numerical values
    scaler = StandardScaler()
    df[numerical_features] = scaler.fit_transform(df[numerical_features])

    # One-hot encoding for categorical features
    encoded_categorical_features = get_dummies(df[categorical_features], drop_first=True)

    # Preprocess timestamp features
    for col in timestamp_features:
        df[col] = to_datetime(df[col])
        for unit in ['year', 'month', 'day', 'hour', 'minute', 'second']:
            df[f"{col}_{unit}"] = getattr(df[col].dt, unit)

    new_timestamp_features = [
        col for col in df.columns
        if col.startswith("EVENT_TIMESTAMP_") or col.startswith("LABEL_TIMESTAMP_")
    ]

    # Combine numerical, categorical and timestamp features
    combined_features = concat([
        df[numerical_features], encoded_categorical_features, df[new_timestamp_features]
    ], axis=1)

    return combined_features, df[textual_features]

def encode_batch(model, batch):
    """
    Encodes a batch of textual data using the Sentence Transformer model.
    """
    return model.encode(batch)

def create_embeddings(textual_features, batch_size=1000, num_workers=3):
    """
    Creates embeddings for textual features using the Sentence Transformer model.
    """
    model = SentenceTransformer("sentence-transformers/all-mpnet-base-v2")

    # Create batches
    batches = [
        textual_features.fillna("").sum(axis=1).iloc[i:i+batch_size].tolist()
        for i in range(0, len(textual_features), batch_size)
    ]

    # Process each batch within the context manager
    with ProcessPoolExecutor(max_workers=num_workers) as executor:
        # Pass the model as an argument to encode_batch
        text_embeddings = list(executor.map(lambda batch: encode_batch(model, batch), batches))

    return concatenate(text_embeddings)

def connect_to_database(dbname, dbuser, dbpass, dbhost, dbport):
    """
    Connects to a PostgreSQL database using the provided configuration.
    """
    conn = f"host={dbhost} port={dbport} dbname={dbname} user={dbuser} password={dbpass}"
    return ConnectionPool(conn, min_size=1, max_size=20)

async def close_connection_pool(conn_pool):
    """
    Closes the connection pool.
    """
    if conn_pool:
        await conn_pool.close()

async def is_transaction_anomaly(conn_pool, embeddings, df):
    """
    Checks if the given embeddings are anomalies based on the transaction anomalies table
    and returns the original dataframe with anomaly scores.
    """
    scores = []
    query = "SELECT MAX(1 - (embedding <=> %s)) FROM transaction_anomalies"

    async with conn_pool.connection() as aconn:
        async with aconn.cursor() as acur:
            for embedding in embeddings:
                await acur.execute(query, (embedding,))
                result = await acur.fetchone()
                scores.append(result[0])

    df['anomaly_score'] = scores
    return df

async def main():
    """
    Main function to execute the anomaly detection process.
    """

    conn_pool = None
    try:
        # Get values from ConfigMap
        config_map_values = get_config_map_values()

        # Get the values from the ConfigMap
        s3_bucket_name = config_map_values.get("S3_BUCKET_NAME")
        s3_path_payment = config_map_values.get("S3_PATH_PAYMENT")
        s3_path_model = config_map_values.get("S3_PATH_MODEL")

        # Local path
        data_folder_path = "./data/"

        # Initialize the s3 client
        s3_client = boto3_client("s3")
        # get S3 file details
        s3_files = list_s3_files(s3_client, s3_bucket_name, s3_path_payment)

        # get csv file names only and last modified must be greater than the date from database
        csv_s3_keys = []
        for s3_file in s3_files:
            if s3_file["Key"].endswith(".csv"):
                csv_s3_keys.append(s3_file["Key"])

        # connect to postgres
        conn_pool = connect_to_database(
            config_map_values.get("DBNAME"),
            config_map_values.get("DBUSER"),
            config_map_values.get("DBPASS"),
            config_map_values.get("SERVICE_PORT") + "." + config_map_values.get("NAMESPACE"),
            config_map_values.get("SERVICE_PORT")
        )

        # for every S3 file
        for csv_s3_key in csv_s3_keys:
            # set local file path
            local_file_path = path.join(data_folder_path, csv_s3_key)
            # download s3 file to local file path
            download_s3_file(s3_client, s3_bucket_name, csv_s3_key, local_file_path)
            # Convert file to pandas dataframe
            df = read_csv(local_file_path)
            if df is not None:
                start1 = default_timer()

                # Create embeddings
                combined_features, textual_features = process_dataframe(df)
                text_embeddings = create_embeddings(textual_features)
                embeddings = concatenate([combined_features.values, text_embeddings], axis=1)

                # Get DataFrame with anomaly scores
                df_with_scores = await is_transaction_anomaly(conn_pool, embeddings, df)

                # Create output filename for the scored data
                output_filename = path.splitext(local_file_path)[0] + '_scored.csv'

                # Save the scored DataFrame to CSV
                df_with_scores.to_csv(output_filename, index=False)

                # Upload the scored file to S3
                scored_s3_key = csv_s3_key.replace(s3_path_payment, s3_path_model)
                scored_s3_key = path.splitext(scored_s3_key)[0] + '_scored.csv'
                upload_s3_file(s3_client, s3_bucket_name, output_filename, scored_s3_key)
                print(f"Scored file saved as '{scored_s3_key}' in S3")

                end1 = default_timer()

                # Print time to process a file
                print(f"File '{csv_s3_key}' processed in {end1 - start1:.2f} seconds")
    finally:
        # Ensure the pool is closed even if an exception occurs
        await close_connection_pool(conn_pool)

if __name__ == "__main__":
    start = default_timer()
    run(main())
    end = default_timer()
    # Print total time in seconds
    print(f"Total time to process all files: {end - start:.2f} seconds")
