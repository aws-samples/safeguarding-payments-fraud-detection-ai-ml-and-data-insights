# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "arn" {
  value = aws_glue_catalog_table.this.arn
}

output "id" {
  value = aws_glue_catalog_table.this.id
}

output "name" {
  value = aws_glue_catalog_table.this.name
}

output "columns" {
  value = local.columns
}
