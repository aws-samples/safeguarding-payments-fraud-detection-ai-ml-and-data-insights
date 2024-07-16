# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  spf_gid = (var.spf_gid == null ? data.terraform_remote_state.s3.outputs.spf_gid : var.spf_gid)
  name = (
    trimspace(var.eks_cluster_name) != "" ? var.eks_cluster_name :
    format("%s-%s-%s", var.q.name, data.aws_region.this.name, local.spf_gid)
  )
}
