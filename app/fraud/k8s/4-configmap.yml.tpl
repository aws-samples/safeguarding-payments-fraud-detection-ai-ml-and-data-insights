# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: v1
kind: ConfigMap
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: config-map
data:
  DBHOST: "localhost"
  DBPORT: "5432"
  DBNAME: "{{SPF_POSTGRES_DB}}"
  DBUSER: "{{SPF_POSTGRES_USER}}"
  DBPASS: "{{SPF_POSTGRES_PWD}}"
  SERVICE_NAME: "postgres"
  SERVICE_PORT: "35432"
  NAMESPACE: "spf-app-postgres-{{SPF_REGION}}-{{SPF_GID}}"
  REGION: "{{SPF_REGION}}"
  S3_BUCKET_NAME: {{SPF_S3_BUCKET}}
  S3_PATH_PAYMENT: payment/
  S3_PATH_MODEL: model/
