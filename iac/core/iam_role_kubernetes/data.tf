# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

data "aws_iam_policy_document" "role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      identifiers = [data.terraform_remote_state.eks.outputs.oidc_provider_arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      variable = format("%s:aud", replace(data.terraform_remote_state.eks.outputs.oidc_provider_url, "https://", ""))
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = format("%s:sub", replace(data.terraform_remote_state.eks.outputs.oidc_provider_url, "https://", ""))
      values   = local.service_accounts
    }
  }
}

data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    skip_region_validation = true

    region = data.aws_region.this.name
    bucket = var.backend_bucket[data.aws_region.this.name]
    key    = format(var.backend_pattern, "eks_cluster")
  }
}

data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    skip_region_validation = true

    region = data.aws_region.this.name
    bucket = var.backend_bucket[data.aws_region.this.name]
    key    = format(var.backend_pattern, "s3_runtime")
  }
}
