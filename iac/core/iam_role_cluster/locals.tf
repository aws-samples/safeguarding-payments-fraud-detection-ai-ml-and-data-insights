# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  spf_gid = (var.spf_gid == null ? data.terraform_remote_state.s3.outputs.spf_gid : var.spf_gid)
  policies = [
    format("arn:%s:iam::aws:policy/AmazonEKSClusterPolicy", data.aws_partition.this.partition),
  ]
}
