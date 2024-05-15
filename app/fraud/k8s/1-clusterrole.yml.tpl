# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: cluster-role
rules:
- apiGroups: [""]
  resources: ["services", "pods"]
  verbs: ["get", "list"]
