# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

data "terraform_remote_state" "glue" {
  backend = "s3"
  config = {
    skip_region_validation = true

    region = data.aws_region.this.name
    bucket = var.spf_backend_bucket[data.aws_region.this.name]
    key    = format(var.spf_backend_pattern, "glue_database")
  }
}

data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    skip_region_validation = true

    region = data.aws_region.this.name
    bucket = var.spf_backend_bucket[data.aws_region.this.name]
    key    = format(var.spf_backend_pattern, "s3_runtime")
  }
}
