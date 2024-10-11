# Run python script to create database objects and insert records if required

echo "Running python script to create database objects and insert records if required"
EMBEDDINGS_ANOMALIES_FILES=embeddings_anomalies.csv \
  EMBEDDINGS_TRANSACTIONS_FILES=embeddings_transactions_01.csv,embeddings_transactions_02.csv,embeddings_transactions_03.csv \
  python3 embeddings_loader.py
