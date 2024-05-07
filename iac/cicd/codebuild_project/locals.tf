# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  spf_gid = (var.spf_gid == null ? data.terraform_remote_state.iam.outputs.spf_gid : var.spf_gid)
  environment_variables = [
    {
      name  = "AWS_DEFAULT_REGION"
      type  = "PLAINTEXT"
      value = data.aws_region.this.name
    },
    {
      name  = "AWS_REGION"
      type  = "PLAINTEXT"
      value = data.aws_region.this.name
    },
    {
      name  = "SPF_REGION"
      type  = "PLAINTEXT"
      value = data.aws_region.this.name
    },
    {
      name  = "SPF_BACKEND"
      type  = "PLAINTEXT"
      value = format("{%s}", join(",", [for key, value in var.backend_bucket : "\"${key}\"=\"${value}\""]))
    },
    {
      name  = "SPF_BUCKET"
      type  = "PLAINTEXT"
      value = var.backend_bucket[data.aws_region.this.name]
    },
    {
      name  = "SPF_ACCOUNT"
      type  = "PLAINTEXT"
      value = data.aws_caller_identity.this.account_id
    },
    {
      name  = "SPF_APP_ARN"
      type  = "PLAINTEXT"
      value = var.app_arn
    },
    {
      name  = "SPF_GID"
      type  = "PLAINTEXT"
      value = local.spf_gid
    },
  ]
}
