import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sentence_transformers import SentenceTransformer
from timeit import default_timer as timer
from sklearn.decomposition import PCA

from dotenv import load_dotenv
import os



def create_embeddings(df):
    # Separate numerical, categorical, text and timestamps features
    numerical_features   = ["billing_zip", "billing_latitude", "billing_longitude", "order_price"]
    categorical_features = ["billing_state", "billing_country", "product_category"]
    textual_features     = ["billing_city", "billing_street", "customer_email", "billing_phone"] #"customer_name","user_agent", "ip_address"
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


def main():
    load_dotenv()

    # Get dataset from the data folder
    dataset = os.environ.get('DATASET')
    df = pd.read_csv(dataset)

    # Copy anomalies event_label=1
    df_anomalies = df.loc[df['EVENT_LABEL'] == 1]
   
    # Copy valid transactions event_label=0
    df_transactions = df.loc[df['EVENT_LABEL'] == 0]
    
    # Create embeddings
    embeddings_anomalies = create_embeddings(df_anomalies)
    embeddings_transactions = create_embeddings(df_transactions)

    # Create csv file in the data folder
    file_anomalies ="./data/" + "embeddings_anomalies.csv"
    file_transactions ="./data/" + "embeddings_transactions.csv"
    np.savetxt(file_anomalies, embeddings_anomalies, delimiter=", ")
    np.savetxt(file_transactions, embeddings_transactions, delimiter=", ")
    
    
if __name__ == '__main__':
    start = timer()
    main()
    end = timer()
    print(end - start)
