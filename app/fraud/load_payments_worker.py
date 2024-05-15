import psycopg2
from pgvector.psycopg2 import register_vector
import boto3
import os
import time
import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

DBUSER = os.environ.get("DBUSER")
DBNAME = os.environ.get("DBNAME")
DBHOST = os.environ.get("DBHOST")
DBPORT = os.environ.get("DBPORT")
DBREGI = os.environ.get("DBREGI")

def create_connection():
    # gets the credentials from .aws/credentials
    client = boto3.client('rds')
    token = client.generate_db_auth_token(DBHostname=DBHOST, Port=DBPORT, DBUsername=DBUSER, Region=DBREGI)
    logger.info('Token length: ' + str(len(token)))
    return psycopg2.connect(host=DBHOST, port=DBPORT, dbname=DBNAME, user=DBUSER, password=token)

def get_records(conn):
    logger.info("Fetching records")
    try:
        cur = conn.cursor()
        cur.execute("""SELECT now()""")
        query_results = cur.fetchall()
        logger.info("Fetched records")
        logger.info(query_results)
    except Exception as e:
        print("Database connection failed due to {}".format(e))

def main():
    logger.info('DBHOST: ' + str(DBHOST))
    logger.info('DBUSER: ' + str(DBUSER))
    logger.info('DBNAME: ' + str(DBNAME))
    logger.info('DBPORT: ' + str(DBPORT))
    logger.info('DBREGI: ' + str(DBREGI))

    # Connect to your postgres DB
    dbconn = create_connection()
    dbconn.set_session(autocommit=True) 
    logger.info("Created connection")

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
    main()
