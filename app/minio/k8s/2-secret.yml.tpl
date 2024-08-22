# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: v1
kind: Secret
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: minio-secret
  creationTimestamp: null
data:
  host: {{ SPF_S3_ENDPOINT_URL }}
  username: {{ SPF_S3_MINIO_USER }}
  password: {{ SPF_S3_MINIO_PASS }}
