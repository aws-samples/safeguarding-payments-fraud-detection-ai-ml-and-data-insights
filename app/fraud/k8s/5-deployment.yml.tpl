# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: fraud
spec:
  selector:
    matchLabels:
      app: fraud-app
  replicas: 1
  template:
    metadata:
      labels:
        app: fraud-app
    spec:
      serviceAccountName: service-account
      containers:
      - name: fraud-app
        image: {{SPF_ECR_URI}}:latest
        stdin: true
        envFrom:
          - configMapRef:
              name: config-map
