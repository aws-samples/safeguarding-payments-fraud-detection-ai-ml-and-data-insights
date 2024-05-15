# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: v1
kind: ServiceAccount
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: service-account
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::{{SPF_ACCOUNT}}:role/{{SPF_ECR_NAME}}
