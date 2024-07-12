# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "arn" {
  value = join(",", aws_vpc_endpoint.this.*.arn)
}

output "id" {
  value = join(",", aws_vpc_endpoint.this.*.id)
}
