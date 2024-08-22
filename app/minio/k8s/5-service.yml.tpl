# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: v1
kind: Service
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: minio-service
  creationTimestamp: null
  labels:
    app: minio
spec:
  ports:
  - port: 9000
    protocol: TCP
    targetPort: 9000
    name: api
  - port: 9090
    protocol: TCP
    targetPort: 9090  
    name: console
  selector:
    app: minio
  type: NodePort
status:
  loadBalancer: {}
