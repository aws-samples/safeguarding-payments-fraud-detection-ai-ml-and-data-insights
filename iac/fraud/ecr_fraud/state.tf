# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "arn" {
  value = aws_ecr_repository.this.arn
}

output "name" {
  value = aws_ecr_repository.this.name
}

output "registry_id" {
  value = aws_ecr_repository.this.registry_id
}

output "repository_url" {
  value = aws_ecr_repository.this.repository_url
}
