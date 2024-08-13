# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  igw_ids = var.spf_subnets_igw_create ? aws_subnet.igw.*.id : data.aws_subnets.igw.ids
  igw_map = {
    for i in split(",", var.spf_subnets_igw_mapping) :
    element(split(":", i), 0) => element(split(":", i), 1) if(
      contains(data.terraform_remote_state.sg.outputs.az_ids, element(split(":", i), 0))
      || contains(data.terraform_remote_state.sg.outputs.lz_ids, element(split(":", i), 0))
    )
  }
  igw_filters = [
    {
      name = local.igw_map == {} ? "availability-zone-id" : "cidr-block"
      values = local.igw_map == {} ? slice(data.terraform_remote_state.sg.outputs.az_ids, 0, 3) : values(local.igw_map)
    },
    {
      name   = "default-for-az"
      values = [data.terraform_remote_state.sg.outputs.vpc_default]
    },
    {
      name   = "vpc-id"
      values = [data.terraform_remote_state.sg.outputs.vpc_id]
    }
  ]
  nat_ids = var.spf_subnets_nat_create ? aws_subnet.nat.*.id : data.aws_subnets.nat.ids
  nat_map = {
    for i in split(",", var.spf_subnets_nat_mapping) :
    element(split(":", i), 0) => element(split(":", i), 1) if(
      contains(data.terraform_remote_state.sg.outputs.az_ids, element(split(":", i), 0))
      || contains(data.terraform_remote_state.sg.outputs.lz_ids, element(split(":", i), 0))
    )
  }
  nat_filters = [
    {
      name   = "cidr-block"
      values = local.nat_map == {} ? [] : values(local.nat_map)
    },
    {
      name   = "vpc-id"
      values = [data.terraform_remote_state.sg.outputs.vpc_id]
    }
  ]
  cagw_ids = var.spf_subnets_cagw_create ? aws_subnet.cagw.*.id : data.aws_subnets.cagw.ids
  cagw_map = {
    for i in split(",", var.spf_subnets_cagw_mapping) :
    element(split(":", i), 0) => element(split(":", i), 1) if(
      contains(data.terraform_remote_state.sg.outputs.wlz_ids, element(split(":", i), 0))
    )
  }
  cagw_filters = [
    {
      name   = "cidr-block"
      values = local.cagw_map == {} ? [] : values(local.cagw_map)
    },
    {
      name   = "vpc-id"
      values = [data.terraform_remote_state.sg.outputs.vpc_id]
    }
  ]
  lgw_ids = data.aws_subnets.lgw.ids
  lgw_map = {
    for i in split(",", var.spf_subnets_lgw_mapping) :
    element(split(":", i), 0) => element(split(":", i), 1) if(
      contains(data.terraform_remote_state.sg.outputs.opz_ids, element(split(":", i), 0))
    )
  }
  lgw_filters = [
    {
      name = "cidr-block"
      values = local.lgw_map == {} ? [] : values(local.lgw_map)
    },
    {
      name   = "vpc-id"
      values = [data.terraform_remote_state.sg.outputs.vpc_id]
    }
  ]
}
