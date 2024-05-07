# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

q = {
  name          = "spf-fraud"
  description   = "SPF FRAUD"
  package_type  = "Image"
  architecture  = "arm64"
  memory_size   = 128
  timeout       = 15
  publish       = false
  storage_size  = 512
  tracing_mode  = "PassThrough"
  reserved      = 20
  logging       = "INFO"

  secrets_manager_ttl  = 300
  cw_group_name_prefix = "/aws/lambda"
  retention_in_days    = 5
  skip_destroy         = true
}
