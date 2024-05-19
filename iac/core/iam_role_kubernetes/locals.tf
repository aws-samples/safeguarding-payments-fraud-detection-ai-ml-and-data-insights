# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  spf_gid = (var.spf_gid == null ? data.terraform_remote_state.s3.outputs.spf_gid : var.spf_gid)
  suffix  = format("%s-%s", data.aws_region.this.name, local.spf_gid)
  policies = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
  ]
  service_accounts = [
    format("system:serviceaccount:spf-app-data-collector-%s:service-account", local.suffix),
    format("system:serviceaccount:spf-app-fraud-%s:service-account", local.suffix),
    format("system:serviceaccount:spf-app-postgres-%s:service-account", local.suffix),
  ]
}
