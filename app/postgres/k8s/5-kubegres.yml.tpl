# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: kubegres.reactive-tech.io/v1
kind: Kubegres
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: postgres
spec:
  replicas: 2
  image: {{SPF_ECR_URI}}:latest
  port: {{SPF_DOCKERFILE_DBPORT}}
  database:
    size: 20Gi
    storageClassName: ebs-{{SPF_SERVICE_AZ1}}
    volumeMount: /var/lib/postgresql/data
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
  resources:
    limits:
      cpu: 1
      memory: 4Gi
    requests:
      cpu: 1
      memory: 2Gi
  scheduler:
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: topology.kubernetes.io/zone
              operator: In
              values:
                - {{SPF_SERVICE_AZ1}}
