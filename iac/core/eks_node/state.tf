# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "node_arn" {
  value = aws_eks_node_group.this.*.arn
}

output "node_id" {
  value = aws_eks_node_group.this.*.id
}

output "node_status" {
  value = aws_eks_node_group.this.*.status
}
