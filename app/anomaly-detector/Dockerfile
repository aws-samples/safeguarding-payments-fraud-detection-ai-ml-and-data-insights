# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

FROM public.ecr.aws/docker/library/python:3.10

WORKDIR /usr/src/app

# ARG SPF_DOCKERFILE_DBHOST=${SPF_DOCKERFILE_DBHOST:-"localhost"}
# ARG SPF_DOCKERFILE_DBNAME=${SPF_DOCKERFILE_DBNAME:-"payments"}
# ARG SPF_DOCKERFILE_DBUSER=${SPF_DOCKERFILE_DBUSER:-"payments"}
# ARG SPF_DOCKERFILE_DBPASS=${SPF_DOCKERFILE_DBPASS:-""}
# ARG SPF_DOCKERFILE_DBPORT=${SPF_DOCKERFILE_DBPORT:-"5432"}

# ENV POSTGRES_DB ${SPF_DOCKERFILE_DBNAME}
# ENV POSTGRES_USER ${SPF_DOCKERFILE_DBHOST}
# ENV POSTGRES_PASSWORD $(echo -n "${SPF_DOCKERFILE_DBPASS}" | base64 --decode)
# ENV PGPASSWORD $(echo -n "${SPF_DOCKERFILE_DBPASS}" | base64 --decode)

# Copy requirements and install dependencies
COPY requirements.txt ./
RUN pip install -r requirements.txt --no-cache-dir

# Download embeddings from S3
RUN curl -LJO https://ws-assets-prod-iad-r-iad-ed304a55c2ca1aee.s3.us-east-1.amazonaws.com/8fc42c16-64b9-4b11-ae2b-20fe38ea021c/embeddings_anomalies.csv
RUN curl -LJO https://ws-assets-prod-iad-r-iad-ed304a55c2ca1aee.s3.us-east-1.amazonaws.com/8fc42c16-64b9-4b11-ae2b-20fe38ea021c/embeddings_transactions_01.csv
RUN curl -LJO https://ws-assets-prod-iad-r-iad-ed304a55c2ca1aee.s3.us-east-1.amazonaws.com/8fc42c16-64b9-4b11-ae2b-20fe38ea021c/embeddings_transactions_02.csv
RUN curl -LJO https://ws-assets-prod-iad-r-iad-ed304a55c2ca1aee.s3.us-east-1.amazonaws.com/8fc42c16-64b9-4b11-ae2b-20fe38ea021c/embeddings_transactions_03.csv

# Copy python scripts
COPY *.csv .
COPY anomaly_detector.py .
COPY embeddings_loader.py .

# Copy init script and SQL file
COPY init.sql /docker-entrypoint-initdb.d/
COPY init.sh /docker-entrypoint-initdb.d/

CMD [ "python", "-u", "./anomaly_detector.py" ]
