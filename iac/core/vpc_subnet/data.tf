# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

data "aws_subnets" "igw" {
  dynamic "filter" {
    for_each = local.igw_filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}

data "aws_subnets" "nat" {
  dynamic "filter" {
    for_each = local.nat_filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}

data "aws_subnets" "cagw" {
  dynamic "filter" {
    for_each = local.cagw_filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}

# @TODO: Implement Local Gateway / Local Zones

# @TODO: Implement Local Gateway / Outpost

data "terraform_remote_state" "sg" {
  backend = "s3"
  config = {
    skip_region_validation = true

    region = data.aws_region.this.name
    bucket = var.backend_bucket[data.aws_region.this.name]
    key    = format(var.backend_pattern, "security_group")
  }
}
