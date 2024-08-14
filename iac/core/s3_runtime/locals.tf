# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  region = (
    data.aws_region.this.name == element(keys(var.spf_backend_bucket), 0)
    ? element(keys(var.spf_backend_bucket), 1) : element(keys(var.spf_backend_bucket), 0)
  )
  spf_gid = (var.spf_gid == null ? (
    data.aws_region.this.name == element(keys(var.spf_backend_bucket), 0)
    ? random_id.this.hex : data.terraform_remote_state.s3.0.outputs.spf_gid
  ) : var.spf_gid)
}
