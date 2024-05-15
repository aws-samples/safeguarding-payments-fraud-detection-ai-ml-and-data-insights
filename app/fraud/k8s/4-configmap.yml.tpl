# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: v1
kind: ConfigMap
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: config-map
data:
  DBHOST: postgres.default
  DBPORT: "5432"
  DBNAME: payments
  DBUSER: postgres
  DBPASS: Postgres123
  REGION: us-east-1
  SERVICE_NAME: postgres
  NAMESPACE: default
  SERVICE_PORT: "31653"
  BUCKET_NAME: fraud-detection-payments
  S3_FILE_PATH: payment/
