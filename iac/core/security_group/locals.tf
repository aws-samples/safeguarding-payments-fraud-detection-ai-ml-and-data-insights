# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  spf_gid = (var.spf_gid == null ? data.terraform_remote_state.s3.outputs.spf_gid : var.spf_gid)
  zone_ids = (
    var.vpc_subnets_source == "wavelength_zones" ?
    {for val in split(",", var.vpc_subnets_wzs): element(split(":", val), 0) => element(split(":", val), 1)} :
    var.vpc_subnets_source == "local_zones" ?
    {for val in split(",", var.vpc_subnets_lzs): element(split(":", val), 0) => element(split(":", val), 1)} :
    var.vpc_subnets_source == "outpost_zones" ?
    {for val in split(",", var.vpc_subnets_ozs): element(split(":", val), 0) => element(split(":", val), 1)} :
    {for val in split(",", var.vpc_subnets_azs): element(split(":", val), 0) => element(split(":", val), 1)}
  )
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
}
