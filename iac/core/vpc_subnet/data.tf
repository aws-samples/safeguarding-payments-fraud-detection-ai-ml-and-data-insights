# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

data "aws_subnets" "igw" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.sg.outputs.vpc_id]
  }

  filter {
    name   = "availability-zone-id"
    values = (
      local.igw_map == {"" = ""}
      ? slice(data.terraform_remote_state.sg.outputs.az_ids, 0, 3)
      : keys(local.igw_map)
    )
  }
}

data "aws_subnets" "nat" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.sg.outputs.vpc_id]
  }

  filter {
    name   = "availability-zone-id"
    values = local.nat_map == {"" = ""} ? [] : keys(local.nat_map)
  }
}

data "aws_subnets" "cagw" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.sg.outputs.vpc_id]
  }

  filter {
    name   = "availability-zone-id"
    values = local.cagw_map == {"" = ""} ? [] : keys(local.cagw_map)
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
