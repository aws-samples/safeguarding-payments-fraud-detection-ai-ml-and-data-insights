# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "aws_ec2_carrier_gateway" "this" {
  count  = var.vpc_subnets_source == "wavelength_zones" ? 1 : 0
  vpc_id = data.terraform_remote_state.sg.outputs.vpc_id
}

resource "aws_route_table" "this" {
  count  = var.vpc_subnets_source == "wavelength_zones" ? 1 : 0
  vpc_id = data.terraform_remote_state.sg.outputs.vpc_id
}

resource "aws_route" "this" {
  count                  = var.vpc_subnets_source == "wavelength_zones" ? 1 : 0
  route_table_id         = element(aws_route_table.this.*.id, 0)
  carrier_gateway_id     = element(aws_ec2_carrier_gateway.this.*.id, 0)
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "this" {
  count          = var.vpc_subnets_source == "wavelength_zones" ? length(data.terraform_remote_state.sg.outputs.subnet_ids) : 0
  subnet_id      = element(data.terraform_remote_state.sg.outputs.subnet_ids, count.index)
  route_table_id = element(aws_route_table.this.*.id, 0)
}
