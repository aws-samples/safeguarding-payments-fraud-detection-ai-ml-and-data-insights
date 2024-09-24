# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: v1
kind: ServiceAccount
metadata:
  namespace: kube-system
  name: ebs-csi-controller-sa
  labels:
    app.kubernetes.io/name: aws-ebs-csi-driver
  annotations:
    {{SPF_SERVICE_PRINCIPAL}}/role-arn: {{SPF_SERVICE_ROLE}}
automountServiceAccountToken: true
