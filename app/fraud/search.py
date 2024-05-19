import numpy as np
from skimage import io
import matplotlib.pyplot as plt
import requests

data = {"inputs": "red sleeveless summer wear"}

res1 = cls_pooling(predictor.predict(data=data)) 
client = boto3.client('secretsmanager')
response = client.get_secret_value( SecretId='rdspg-vector-secret' )
database_secrets = json.loads(response['SecretString'])
dbhost = database_secrets['host']
dbport = database_secrets['port']
dbuser = database_secrets['username']
dbpass = database_secrets['password']
dbconn = psycopg2.connect(host=dbhost, user=dbuser, password=dbpass, port=dbport, connect_timeout=10)
dbconn.set_session(autocommit=True)

cur = dbconn.cursor()

cur.execute("""SELECT id, column1, column2, column3, embeddings
  FROM fraud_payments
  ORDER BY embeddings <-> %s limit 2;""",
  (np.array(res1),))

r = cur.fetchall()
urls = []

for x in r:
    url = x[1].split('?')[0]
    urldata = requests.get(url, timeout=15).content
    print("Product Item Id: " + str(x[0]))
    a = io.imread(url)
    plt.imshow(a)
    plt.axis('off')
    plt.show()

cur.close()
dbconn.close()
