"""
This script imports data from s3 to PostgreSQL database
"""

import os
import gzip
import boto3
import psycopg2

def initialize_s3_client():
    """
    Initialize the s3 client
    """
    aws_access_key_id = os.environ.get("AWS_ACCESS_KEY_ID")
    aws_secret_access_key = os.environ.get("AWS_SECRET_ACCESS_KEY")
    region_name = os.environ.get("REGION_NAME")
    s3_client = boto3.client(
        service_name="s3",
        region_name=region_name,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )
    return s3_client


def list_s3_files(s3_client):
    """
    Return S3 files for a specific bucket and prefix
    """
    bucket_name = os.environ.get("BUCKET_NAME")
    s3_file_path = os.environ.get("S3_FILE_PATH","")
    s3_files = []
    response = s3_client.list_objects_v2(
        Bucket = bucket_name,
        Prefix = s3_file_path
    )
    if response.get("KeyCount")>0:
        s3_files = response.get("Contents")
    return s3_files


def download_s3_file(s3_client, s3_file, local_file_path):
    """
    Download the file from s3 to local
    """
    bucket_name = os.environ.get("BUCKET_NAME")
    # get local folder path
    local_folder_path = os.path.split(local_file_path)[0]
    # create local folder if not exists
    os.makedirs(local_folder_path, exist_ok=True)
    # download file from s3 to local
    s3_client.download_file(bucket_name, s3_file, local_file_path)


def load_csv_to_sql(local_file_path):
    """
    Load contents of csv file to sql table
    """
    sql_host = os.environ.get("SQL_HOST")
    sql_user = os.environ.get("SQL_USER")
    sql_password = os.environ.get("SQL_PASSWORD")
    sql_db = os.environ.get("SQL_DB")
    sql_table = os.environ.get("SQL_TABLE")
    # create load query from template
    load_query = """
    COPY {sql_table} FROM STDIN WITH CSV HEADER DELIMITER AS ',' QUOTE AS '\"' ;
    """.format(
        sql_table=sql_table
    )
    # Create database connection
    sql_connection = psycopg2.connect(
        host=sql_host,
        user=sql_user,
        password=sql_password,
        database=sql_db
    )
    # create sql cursor
    sql_cursor = sql_connection.cursor()
    # execute load query
    try:
        # decompress gzip file
        with gzip.open(filename=local_file_path, mode='rb') as local_file:
            sql_cursor.copy_expert(sql=load_query, file=local_file)
        sql_connection.commit()
    except Exception as load_exception:
        sql_connection.rollback()
        raise Exception("SQL LOAD error: " + str(load_exception)) from load_exception
    # close sql cursor and connection
    sql_cursor.close()
    sql_connection.close()


def main():
    """
    Main function which imports the data from s3 to PostgreSQL database
    """
    # get local folder path from environment variable
    data_folder_path = "./data/"
    # Initialize the s3 client
    s3_client = initialize_s3_client()
    # get S3 file details
    s3_files = list_s3_files(s3_client=s3_client)
    # get gzip csv file names only
    csv_s3_keys = [s3_file["Key"] for s3_file in s3_files if s3_file["Key"].endswith(".csv.gz")]
    # for every S3 file
    for csv_s3_key in csv_s3_keys:
        # set local file path
        local_file_path = os.path.join(data_folder_path, csv_s3_key)
        # download s3 file to local file path
        download_s3_file(s3_client, csv_s3_key, local_file_path)
        # load local file contents to sql table
        load_csv_to_sql(local_file_path)


if __name__ == "__main__":
    main()