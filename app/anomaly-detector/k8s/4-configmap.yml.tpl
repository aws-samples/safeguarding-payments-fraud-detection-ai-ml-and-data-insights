# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: v1
kind: ConfigMap
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: config-map
data:
  DBHOST: "{{SPF_DOCKERFILE_DBHOST}}"
  DBNAME: "{{SPF_DOCKERFILE_DBNAME}}"
  DBUSER: "{{SPF_DOCKERFILE_DBUSER}}"
  DBPASS: "{{SPF_DOCKERFILE_DBPASS}}"
  DBPORT: "{{SPF_DOCKERFILE_DBPORT}}"
  SERVICE_PORT: "{{SPF_SERVICE_DBPORT}}"
  SERVICE_NAME: "{{SPF_SERVICE_DBNAME}}"
  NAMESPACE: "{{SPF_SERVICE_NAMESPACE}}"
  REGION: "{{SPF_REGION}}"
  S3_BUCKET_NAME: {{SPF_S3_BUCKET}}
  S3_PATH_PAYMENT: data-collector/
  S3_PATH_MODEL: anomaly-detector/
  DATA_FOLDER_PATH: ./data/
