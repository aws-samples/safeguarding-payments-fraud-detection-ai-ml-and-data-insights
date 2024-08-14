# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

data "aws_service_principal" "this" {
  service_name = "s3"
  region       = data.aws_region.this.name
}

data "terraform_remote_state" "s3" {
  count = (
    data.aws_region.this.name == element(keys(var.spf_backend_bucket), 1)
    && data.aws_region.this.name != local.region ? 1 : 0
  )
  backend = "s3"
  config = {
    skip_region_validation = true

    region = element(keys(var.spf_backend_bucket), 0)
    bucket = var.spf_backend_bucket[element(keys(var.spf_backend_bucket), 0)]
    key    = format(var.spf_backend_pattern, "s3_runtime")
  }
}
