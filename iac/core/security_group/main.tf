# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "aws_security_group" "this" {
  name        = format("%s-%s-%s", var.q.name, data.aws_region.this.name, local.spf_gid)
  description = var.q.description
  vpc_id      = data.aws_vpc.this.id

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      description      = try(ingress.value.description, null)
      from_port        = try(ingress.value.from_port, null)
      to_port          = try(ingress.value.to_port, null)
      protocol         = try(ingress.value.protocol, null)
      cidr_blocks      = try(split(",", ingress.value.cidr_blocks), null)
      ipv6_cidr_blocks = try(split(",", ingress.value.ipv6_cidr_blocks), null)
      prefix_list_ids  = try(split(",", ingress.value.prefix_list_ids), null)
      security_groups  = try(split(",", ingress.value.security_groups), null)
      self             = try(ingress.value.self, null)
    }
  }

  dynamic "egress" {
    for_each = local.egress_rules
    content {
      description      = try(egress.value.description, null)
      from_port        = try(egress.value.from_port, null)
      to_port          = try(egress.value.to_port, null)
      protocol         = try(egress.value.protocol, null)
      cidr_blocks      = try(split(",", egress.value.cidr_blocks), null)
      ipv6_cidr_blocks = try(split(",", egress.value.ipv6_cidr_blocks), null)
      prefix_list_ids  = try(split(",", egress.value.prefix_list_ids), null)
      security_groups  = try(split(",", egress.value.security_groups), null)
      self             = try(egress.value.self, null)
    }
  }
}
