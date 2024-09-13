# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "kubernetes_service_account" "this" {
  automount_service_account_token = true
  metadata {
    name = "ebs-csi-controller-sa"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name" = "aws-ebs-csi-driver"
    }
    annotations = {
      format("%s/role-arn", data.aws_service_principal.this.name) = data.terraform_remote_state.iam.outputs.arn
    }
  }
}
