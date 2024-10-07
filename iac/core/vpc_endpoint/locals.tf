# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  gateways   = ["dynamodb", "s3"]
  interfaces = split(",", try(var.spf_vpce_mapping, ""))
  route_table_ids = {
    igw  = data.terraform_remote_state.subnet.outputs.igw_route_table_id,
    nat  = data.terraform_remote_state.subnet.outputs.nat_route_table_id,
    cagw = data.terraform_remote_state.subnet.outputs.cagw_route_table_id,
  }
  subnet_ids = (
    length(data.terraform_remote_state.subnet.outputs.nat_subnet_ids) > 0
    ? data.terraform_remote_state.subnet.outputs.nat_subnet_ids
    : data.terraform_remote_state.subnet.outputs.igw_subnet_ids
  )
}
