# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "arn" {
  value = aws_glue_catalog_database.this.arn
}

output "id" {
  value = aws_glue_catalog_database.this.id
}

output "name" {
  value = aws_glue_catalog_database.this.name
}
