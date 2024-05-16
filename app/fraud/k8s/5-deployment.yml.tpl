# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: spf-fraud
spec:
  selector:
    matchLabels:
      app: spf-fraud-image
  replicas: 1
  template:
    metadata:
      labels:
        app: spf-fraud-image
    spec:
      serviceAccountName: service-account
      containers:
      - image: {{SPF_ECR_URI}}:latest
        name: spf-fraud-image
        stdin: true
        envFrom:
          - configMapRef:
              name: config-map