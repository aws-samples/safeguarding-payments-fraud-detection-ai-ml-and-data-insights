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

COPY init.sql /docker-entrypoint-initdb.d/

COPY requirements.txt ./
RUN pip install -r requirements.txt --no-cache-dir

COPY anomaly_detector.py .

CMD [ "python", "-u", "./anomaly_detector.py" ]
