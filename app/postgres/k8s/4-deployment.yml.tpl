# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      serviceAccountName: service-account
      containers:
        - name: postgres
          image: {{SPF_ECR_URI}}:latest
          imagePullPolicy: "IfNotPresent"
          ports:
            - containerPort: {{SPF_DOCKERFILE_DBPORT}}
          env:
            - name: POSTGRES_USER
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: POSTGRES_USER
                  optional:
                    false
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: POSTGRES_PASSWORD
                  optional:
                    false
            - name: POSTGRES_PORT
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: POSTGRES_PORT
                  optional:
                    false
          volumeMounts:
            - name: postgres-data
              mountPath: /var/lib/postgresql/data
      volumes:
        - name: postgres-data
          persistentVolumeClaim:
            claimName: postgres-pv-claim
