# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "aws_iam_role" "this" {
  name               = format("%s-%s-%s", var.q.name, data.aws_region.this.name, local.spf_gid)
  description        = var.q.description
  path               = var.q.path
  assume_role_policy = data.aws_iam_policy_document.role.json

  tags = {
    "alpha.eksctl.io/cluster-name"                = data.terraform_remote_state.eks.outputs.id
    "alpha.eksctl.io/iamserviceaccount-name"      = element(local.service_accounts, 0)
    "alpha.eksctl.io/eksctl-version"              = data.terraform_remote_state.eks.outputs.eksctl_version
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = data.terraform_remote_state.eks.outputs.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = length(local.policies)
  role       = aws_iam_role.this.name
  policy_arn = element(local.policies, count.index)
}
