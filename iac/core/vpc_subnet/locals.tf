# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  igw_map = {for i in split(",", var.subnets_igw_mapping): element(split(":", i), 0) => element(split(":", i), 1)}
  igw_ids = var.subnets_igw_create ? aws_subnet.igw.*.id : data.aws_subnets.igw.ids
  nat_map = {for i in split(",", var.subnets_nat_mapping): element(split(":", i), 0) => element(split(":", i), 1)}
  nat_ids = var.subnets_nat_create ? aws_subnet.nat.*.id : data.aws_subnets.nat.ids
  cagw_map = {for i in split(",", var.subnets_cagw_mapping): element(split(":", i), 0) => element(split(":", i), 1)}
  cagw_ids = var.subnets_cagw_create ? aws_subnet.cagw.*.id : data.aws_subnets.cagw.ids
  # lzn_map = {for i in split(",", var.subnets_lzn_mapping): element(split(":", i), 0) => element(split(":", i), 1)}
  # lzn_ids = var.subnets_lzn_create ? aws_subnet.lzn.*.id : data.aws_subnets.lzn.ids
  # lgw_map = {for i in split(",", var.subnets_lgw_mapping): element(split(":", i), 0) => element(split(":", i), 1)}
  # lgw_ids = var.subnets_lgw_create ? aws_subnet.lgw.*.id : data.aws_subnets.lgw.ids
}
