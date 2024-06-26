# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

data "aws_vpcs" "this" {
  filter {
    name   = var.vpc_id != "" ? "vpc-id" : "tag:Name"
    values = [var.vpc_id != "" ? var.vpc_id : var.q.vpc_name]
  }
}

data "aws_vpc" "this" {
  id      = try(element(data.aws_vpcs.this.ids, 0), null)
  default = try(element(data.aws_vpcs.this.ids, 0), null) == null ? true : false
}

data "aws_availability_zones" "az" {
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_availability_zones" "lz" {
  all_availability_zones = true
  filter {
    name   = "zone-type"
    values = ["local-zone"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_availability_zones" "wlz" {
  all_availability_zones = true
  filter {
    name   = "zone-type"
    values = ["wavelength-zone"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    skip_region_validation = true

    region = data.aws_region.this.name
    bucket = var.backend_bucket[data.aws_region.this.name]
    key    = format(var.backend_pattern, "s3_runtime")
  }
}
