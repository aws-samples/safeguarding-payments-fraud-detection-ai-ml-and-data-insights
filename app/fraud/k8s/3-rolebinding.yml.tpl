# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: cluster-role-binding
subjects:
- kind: ServiceAccount
  name: service-account
  namespace: {{SPF_ECR_NAME}}
roleRef:
  kind: ClusterRole 
  name: cluster-role
  apiGroup: rbac.authorization.k8s.io
