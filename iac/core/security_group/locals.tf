# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  spf_gid = (var.spf_gid == null ? data.terraform_remote_state.s3.outputs.spf_gid : var.spf_gid)
  ingress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      self      = true
    },
  ]
  egress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      self      = true
    },
  ]
  outposts = {
    for i in split(",", var.spf_outpost_names) :
    i => format(
      "arn:%s:outposts:%s:%s:outpost/%s",
      data.aws_partition.this.partition,
      data.aws_region.this.name,
      data.aws_caller_identity.this.account_id,
      i) if i != ""
  }
}
