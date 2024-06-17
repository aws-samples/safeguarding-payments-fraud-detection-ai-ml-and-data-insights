# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "igw_subnet_ids" {
  value = local.igw_ids
}

output "igw_route_table_id" {
  value = length(aws_route_table.igw.*.id) > 0 ? element(aws_route_table.igw.*.id, 0) : ""
}

output "nat_subnet_ids" {
  value = local.nat_ids
}

output "nat_route_table_id" {
  value = length(aws_route_table.nat.*.id) > 0 ? element(aws_route_table.nat.*.id, 0) : ""
}

output "cagw_subnet_ids" {
  value = local.cagw_ids
}

output "cagw_route_table_id" {
  value = length(aws_route_table.cagw.*.id) > 0 ? element(aws_route_table.cagw.*.id, 0) : ""
}

# @TODO: Implement Local Gateway / Outpost
