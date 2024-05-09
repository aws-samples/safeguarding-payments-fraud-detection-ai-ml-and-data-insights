# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "arn" {
  value = aws_iam_role.this.arn
}

output "id" {
  value = aws_iam_role.this.id
}

output "unique_id" {
  value = aws_iam_role.this.unique_id
}

output "create_date" {
  value = aws_iam_role.this.create_date
}

output "name" {
  value = aws_iam_role.this.name
}
