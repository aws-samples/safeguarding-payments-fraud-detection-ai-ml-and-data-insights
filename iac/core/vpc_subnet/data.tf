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

data "aws_subnets" "lgw" {
  dynamic "filter" {
    for_each = local.lgw_filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}

data "terraform_remote_state" "sg" {
  backend = "s3"
  config = {
    skip_region_validation = true

    region = data.aws_region.this.name
    bucket = var.spf_backend_bucket[data.aws_region.this.name]
    key    = format(var.spf_backend_pattern, "security_group")
  }
}
