# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "arn" {
  value = {
    for idx, val in aws_vpc_endpoint.this.*.arn:
    local.interfaces[idx] => val
  }
}

output "id" {
  value = {
    for idx, val in aws_vpc_endpoint.this.*.id:
    local.interfaces[idx] => val
  }
}
