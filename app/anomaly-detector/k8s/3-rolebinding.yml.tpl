# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: service-account
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: service-account
subjects:
  - kind: ServiceAccount
    namespace: {{SPF_ECR_NAME}}
    name: service-account
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: service-account
rules:
  - apiGroups: [""]
    resources: ["namespaces", "pods", "serviceaccounts"]
    verbs: ["get", "watch", "list"]
