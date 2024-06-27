# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: anomaly-detector
spec:
  selector:
    matchLabels:
      app: anomaly-detector-app
  replicas: 1
  template:
    metadata:
      labels:
        app: anomaly-detector-app
    spec:
      serviceAccountName: service-account
      containers:
      - name: anomaly-detector-app
        image: {{SPF_ECR_URI}}:latest
        stdin: true
        envFrom:
          - configMapRef:
              name: config-map
