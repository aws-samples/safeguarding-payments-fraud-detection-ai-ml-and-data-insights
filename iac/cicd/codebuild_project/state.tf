# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "arn" {
  value = aws_codebuild_project.this.arn
}

output "id" {
  value = aws_codebuild_project.this.id
}

output "badge_url" {
  value = aws_codebuild_project.this.badge_url
}
