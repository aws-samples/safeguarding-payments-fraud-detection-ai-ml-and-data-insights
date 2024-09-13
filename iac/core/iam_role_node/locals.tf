# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  spf_gid = (var.spf_gid == null ? data.terraform_remote_state.s3.outputs.spf_gid : var.spf_gid)
  policies = [
    aws_iam_policy.this.arn,
    format("arn:%s:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy", data.aws_partition.this.partition),
    format("arn:%s:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", data.aws_partition.this.partition),
    format("arn:%s:iam::aws:policy/AmazonEKSWorkerNodePolicy", data.aws_partition.this.partition),
    format("arn:%s:iam::aws:policy/AmazonEKS_CNI_Policy", data.aws_partition.this.partition),
  ]
}
