# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: minio
spec:
  replicas: 1
  selector:
    matchLabels:
      app: minio
  template:
    metadata:
      labels:
        app: minio
    spec:
      serviceAccountName: service-account
      containers:
      - name: minio
        image: {{SPF_ECR_URI}}:latest
        command:
        - /bin/bash
        - -c
        args: 
        - minio server /data --console-address :9090
        volumeMounts:
        - name: minio-volume
          mountPath: /data
      nodeSelector:
        # kubernetes.io/hostname: kubealpha.local # Specify a node label associated to the Worker Node on which you want to deploy the pod.
      volumes:
      - name: minio-volume
        hostPath:
          path: /mnt/data
          type: DirectoryOrCreate
