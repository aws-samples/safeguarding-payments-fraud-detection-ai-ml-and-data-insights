# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "cgw_arn" {
  value = join(",", aws_ec2_carrier_gateway.this.*.arn)
}

output "cgw_id" {
  value = join(",", aws_ec2_carrier_gateway.this.*.id)
}

output "cgw_owner_id" {
  value = join(",", aws_ec2_carrier_gateway.this.*.owner_id)
}

output "rt_id" {
  value = join(",", aws_route.this.*.id)
}

output "rt_instance_id" {
  value = join(",", aws_route.this.*.instance_id)
}

output "rt_instance_owner_id" {
  value = join(",", aws_route.this.*.instance_owner_id)
}

output "rtb_arn" {
  value = join(",", aws_route_table.this.*.arn)
}

output "rtb_id" {
  value = join(",", aws_route_table.this.*.id)
}

output "rtb_owner_id" {
  value = join(",", aws_route_table.this.*.owner_id)
}

output "rtb_assoc_id" {
  value = join(",", aws_route_table_association.this.*.id)
}
