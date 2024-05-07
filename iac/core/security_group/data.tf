# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

data "aws_vpcs" "this" {
  filter {
    name   = var.vpc_id != "" ? "vpc-id" : "tag:Name"
    values = [var.vpc_id != "" ? var.vpc_id : var.q.vpc_name]
  }
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [length(data.aws_vpcs.this.ids) > 0 ? element(data.aws_vpcs.this.ids, 0) : "vpc-id"]
  }

  filter {
    name   = local.zone_ids == {"" = ""} ? "availability-zone" : "availability-zone-id"
    values = local.zone_ids == {"" = ""} ? [
      format("%sa", data.aws_region.this.name),
      format("%sb", data.aws_region.this.name),
      format("%sc", data.aws_region.this.name),
    ] : keys(local.zone_ids)
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
