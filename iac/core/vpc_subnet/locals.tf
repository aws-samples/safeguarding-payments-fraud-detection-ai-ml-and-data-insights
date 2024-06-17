# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  igw_ids = var.subnets_igw_create ? aws_subnet.igw.*.id : data.aws_subnets.igw.ids
  igw_map = {
    for i in split(",", var.subnets_igw_mapping) :
    element(split(":", i), 0) => element(split(":", i), 1) if(
      contains(data.terraform_remote_state.sg.outputs.az_ids, element(split(":", i), 0))
      || contains(data.terraform_remote_state.sg.outputs.lz_ids, element(split(":", i), 0))
    )
  }
  igw_filters = [
    {
      name = "availability-zone-id"
      values = (
        local.igw_map == {}
        ? slice(data.terraform_remote_state.sg.outputs.az_ids, 0, 3)
        : keys(local.igw_map)
      )
    },
    {
      name   = "default-for-az"
      values = [data.terraform_remote_state.sg.outputs.vpc_default]
    },
  ]
  nat_ids = var.subnets_nat_create ? aws_subnet.nat.*.id : data.aws_subnets.nat.ids
  nat_map = {
    for i in split(",", var.subnets_nat_mapping) :
    element(split(":", i), 0) => element(split(":", i), 1) if(
      contains(data.terraform_remote_state.sg.outputs.az_ids, element(split(":", i), 0))
      || contains(data.terraform_remote_state.sg.outputs.lz_ids, element(split(":", i), 0))
    )
  }
  nat_filters = [
    {
      name   = "availability-zone-id"
      values = local.nat_map == {} ? [] : keys(local.nat_map)
    }
  ]
  cagw_ids = var.subnets_cagw_create ? aws_subnet.cagw.*.id : data.aws_subnets.cagw.ids
  cagw_map = {
    for i in split(",", var.subnets_cagw_mapping) :
    element(split(":", i), 0) => element(split(":", i), 1) if(
      contains(data.terraform_remote_state.sg.outputs.wlz_ids, element(split(":", i), 0))
    )
  }
  cagw_filters = [
    {
      name   = "availability-zone-id"
      values = local.cagw_map == {} ? [] : keys(local.cagw_map)
    },
  ]
}
