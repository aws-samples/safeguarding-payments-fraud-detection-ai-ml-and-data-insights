# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  spf_gid = (var.spf_gid == null ? data.terraform_remote_state.s3.outputs.spf_gid : var.spf_gid)
  name = (
    try(trimspace(var.spf_eks_cluster_name), "") != "" ? var.spf_eks_cluster_name :
    format("%s-%s-%s", var.q.name, data.aws_region.this.name, local.spf_gid)
  )
  roles = try(trimspace(var.spf_eks_access_roles), "") != "" ? split(",", var.spf_eks_access_roles) : []
}
