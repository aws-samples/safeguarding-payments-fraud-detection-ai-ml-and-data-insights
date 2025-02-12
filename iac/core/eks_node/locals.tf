# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  spf_gid = (var.spf_gid == null ? data.terraform_remote_state.s3.outputs.spf_gid : var.spf_gid)
  labels = {
    for i in split(",", var.q.labels) :
    element(split(":", i), 0) => element(split(":", i), 1)
    if element(split(":", i), 0) != ""
  }
  namespaces = concat(split(",", var.q.fargate_names), values({
    for val in split(",", var.q.app_namespaces) :
    val => format("%s-%s-%s", val, data.aws_region.this.name, local.spf_gid)
    if val != ""
  }))
  subnets = (
    length(data.terraform_remote_state.subnet.outputs.cagw_subnet_ids) > 0
    ? data.terraform_remote_state.subnet.outputs.cagw_subnet_ids
    : length(data.terraform_remote_state.subnet.outputs.nat_subnet_ids) > 0
    ? data.terraform_remote_state.subnet.outputs.nat_subnet_ids
    : data.terraform_remote_state.subnet.outputs.igw_subnet_ids
  )
  subnet_ids = slice(
    local.subnets, 0,
    var.q.desired_size > length(local.subnets)
    ? length(local.subnets)
    : var.q.desired_size
  )
}
