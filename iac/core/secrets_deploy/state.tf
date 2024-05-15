# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "arn" {
  value = aws_secretsmanager_secret.this.arn
}

output "id" {
  value = aws_secretsmanager_secret.this.id
}

output "replica_status" {
  value = aws_secretsmanager_secret.this.replica.status
}

output "replica_message" {
  value = aws_secretsmanager_secret.this.replica.status_message
}

output "replica_last_accessed_date" {
  value = aws_secretsmanager_secret.this.replica.last_accessed_date
}

# output "secret_arn" {
#   value = aws_secretsmanager_secret_version.this.arn
# }

# output "secret_id" {
#   value = aws_secretsmanager_secret_version.this.id
# }

# output "secret_version_id" {
#   value = aws_secretsmanager_secret_version.this.version_id
# }
