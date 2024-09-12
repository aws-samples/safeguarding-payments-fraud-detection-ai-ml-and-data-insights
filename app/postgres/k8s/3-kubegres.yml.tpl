# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: kubegres.reactive-tech.io/v1
kind: Kubegres
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: postgres
spec:
   replicas: 3
   image: {{SPF_ECR_URI}}:latest
   port: {{SPF_DOCKERFILE_DBPORT}}
   database:
      size: 10Gi
   env:
      - name: POSTGRES_PASSWORD
        valueFrom:
           secretKeyRef:
              name: postgres-secret
              key: POSTGRES_PASSWORD
      - name: POSTGRES_REPLICATION_PASSWORD
        valueFrom:
           secretKeyRef:
              name: postgres-secret
              key: POSTGRES_REPLICATION_PASSWORD
