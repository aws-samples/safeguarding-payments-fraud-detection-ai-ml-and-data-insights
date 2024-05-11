# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  spf_gid    = (var.spf_gid == null ? data.terraform_remote_state.s3.outputs.spf_gid : var.spf_gid)
  subnet_ids = (
    length(data.terraform_remote_state.subnet.outputs.cagw_subnet_ids) > 0 ?
    data.terraform_remote_state.subnet.outputs.cagw_subnet_ids :
    length(data.terraform_remote_state.subnet.outputs.nat_subnet_ids) > 0 ?
    data.terraform_remote_state.subnet.outputs.nat_subnet_ids :
    data.terraform_remote_state.subnet.outputs.igw_subnet_ids
  )
  labels = {for i in split(",", var.q.labels): element(split(":", i), 0) => element(split(":", i), 1)}
}
