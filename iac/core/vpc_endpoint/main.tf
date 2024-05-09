# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "aws_vpc_endpoint" "this" {
  count               = trimspace(element(local.interfaces, 0)) != "" ? length(local.interfaces) : 0
  vpc_id              = data.terraform_remote_state.sg.outputs.vpc_id
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  service_name        = format("com.amazonaws.%s.%s", data.aws_region.this.name, element(local.interfaces, count.index))
  subnet_ids          = concat(
    data.terraform_remote_state.subnet.outputs.igw_subnet_ids,
    data.terraform_remote_state.subnet.outputs.nat_subnet_ids
  )
  security_group_ids  = [data.terraform_remote_state.sg.outputs.id]
  depends_on = [aws_vpc_endpoint.that]
}

resource "aws_vpc_endpoint" "that" {
  count               = trimspace(element(local.gateways, 0)) != "" ? length(local.gateways) : 0
  vpc_id              = data.terraform_remote_state.sg.outputs.vpc_id
  vpc_endpoint_type   = "Gateway"
  service_name        = format("com.amazonaws.%s.%s", data.aws_region.this.name, element(local.gateways, count.index))
}
