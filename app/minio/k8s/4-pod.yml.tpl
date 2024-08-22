# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: v1
kind: Pod
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: minio
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
    - mountPath: /data
      name: minio-volume
  nodeSelector:
    #kubernetes.io/hostname: kubealpha.local # Specify a node label associated to the Worker Node on which you want to deploy the pod.
  volumes:
  - name: minio-volume
    hostPath:
      path: /mnt/disk1/data
      type: DirectoryOrCreate
