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
      value = trimspace(var.app_arn) == "" ? data.terraform_remote_state.app.outputs.arn : var.app_arn
    },
    {
      name  = "SPF_GID"
      type  = "PLAINTEXT"
      value = local.spf_gid
    },
    {
      name  = "SPF_DIR"
      type  = "PLAINTEXT"
      value = "iac/core"
    },
    {
      name  = "SPF_VPC_ID"
      type  = "PLAINTEXT"
      value = ""
    },
    {
      name  = "SPF_VPCE_MAPPING"
      type  = "PLAINTEXT"
      value = ""
    },
    {
      name  = "SPF_SUBNETS_IGW_CREATE"
      type  = "PLAINTEXT"
      value = "false"
    },
    {
      name  = "SPF_SUBNETS_IGW_MAPPING"
      type  = "PLAINTEXT"
      value = ""
    },
    {
      name  = "SPF_SUBNETS_NAT_CREATE"
      type  = "PLAINTEXT"
      value = "false"
    },
    {
      name  = "SPF_SUBNETS_NAT_MAPPING"
      type  = "PLAINTEXT"
      value = ""
    },
    {
      name  = "SPF_SUBNETS_CAGW_CREATE"
      type  = "PLAINTEXT"
      value = "false"
    },
    {
      name  = "SPF_SUBNETS_CAGW_MAPPING"
      type  = "PLAINTEXT"
      value = ""
    },
    {
      name  = "SPF_EKS_CLUSTER_NAME"
      type  = "PLAINTEXT"
      value = format("spf-eks-cluster-%s-%s", data.aws_region.this.name, local.spf_gid)
    },
    {
      name  = "SPF_EKS_NODE_TYPE"
      type  = "PLAINTEXT"
      value = "fargate"
    },
    {
      name  = "SPF_EKS_NODE_ARCH"
      type  = "PLAINTEXT"
      value = "x86"
    },
    {
      name  = "SPF_EKS_NODE_EC2"
      type  = "PLAINTEXT"
      value = ""
    },
    {
      name  = "SPF_EKS_NODE_EBS"
      type  = "PLAINTEXT"
      value = ""
    },
  ]
}
