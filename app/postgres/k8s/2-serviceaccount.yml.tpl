# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: v1
kind: ServiceAccount
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: service-account
  annotations:
    {{SPF_SERVICE_PRINCIPAL}}/role-arn: {{SPF_SERVICE_ROLE}}
