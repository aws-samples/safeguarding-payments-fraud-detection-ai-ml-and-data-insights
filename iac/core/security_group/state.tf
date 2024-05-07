# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "arn" {
  value = aws_security_group.this.arn
}

output "id" {
  value = aws_security_group.this.id
}

output "owner_id" {
  value = aws_security_group.this.owner_id
}

output "subnet_ids" {
  value = var.vpc_subnets_create ? aws_subnet.this.*.id : data.aws_subnets.this.ids
}

output "vpc_id" {
  value = aws_security_group.this.vpc_id
}
