# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "igw_subnet_ids" {
  value = local.igw_ids
}

output "nat_subnet_ids" {
  value = local.nat_ids
}

output "cagw_subnet_ids" {
  value = local.cagw_ids
}

# @TODO: Implement Local Gateway / Local Zones

# @TODO: Implement Local Gateway / Outpost
