import psycopg2
from pgvector.psycopg2 import register_vector
import boto3 
import json


client = boto3.client('secretsmanager')

response = client.get_secret_value(
    SecretId='rdspg-vector-secret'
)
database_secrets = json.loads(response['SecretString'])

dbhost = database_secrets['host']
dbport = database_secrets['port']
dbuser = database_secrets['username']
dbpass = database_secrets['password']

dbconn = psycopg2.connect(host=dbhost, user=dbuser, password=dbpass,
    port=dbport, connect_timeout=10)
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