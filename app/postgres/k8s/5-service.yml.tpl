# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: v1
kind: Service
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: postgres
  labels:
    app: postgres
spec:
  ports:
    - protocol: TCP
      port: {{SPF_SERVICE_DBPORT}}
      targetPort: {{SPF_DOCKERFILE_DBPORT}}
  selector:
    app: postgres
