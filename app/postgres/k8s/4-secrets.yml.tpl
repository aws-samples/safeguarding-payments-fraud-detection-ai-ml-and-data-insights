# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: v1
kind: Secret
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: postgres-secret
type: Opaque
data:
  POSTGRES_PORT: "{{SPF_DOCKERFILE_DBPORT}}"
stringData:
  POSTGRES_PASSWORD: "{{SPF_DOCKERFILE_DBPASS}}"
  POSTGRES_REPLICATION_PASSWORD: "{{SPF_DOCKERFILE_DBPASS}}"
