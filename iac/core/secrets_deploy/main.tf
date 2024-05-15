# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "aws_secretsmanager_secret" "this" {
  name                    = format("%s-%s-%s", var.q.name, data.aws_region.this.name, local.spf_gid)
  description             = var.q.description
  recovery_window_in_days = var.q.days

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode(local.secret)

  lifecycle {
    create_before_destroy = true
  }
}
