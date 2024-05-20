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

output "vpc_id" {
  value = aws_security_group.this.vpc_id
}

output "az_ids" {
  value = data.aws_availability_zones.az.zone_ids
}

output "az_names" {
  value = data.aws_availability_zones.az.names
}

output "az_group_names" {
  value = data.aws_availability_zones.az.group_names
}

output "lz_ids" {
  value = data.aws_availability_zones.lz.zone_ids
}

output "lz_names" {
  value = data.aws_availability_zones.lz.names
}

output "lz_group_names" {
  value = data.aws_availability_zones.lz.group_names
}
