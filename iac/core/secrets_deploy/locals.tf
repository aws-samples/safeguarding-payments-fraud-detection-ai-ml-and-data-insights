# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  spf_gid = (var.spf_gid == null ? data.terraform_remote_state.s3.outputs.spf_gid : var.spf_gid)
  secret  = {
    SPF_POSTGRES_DB = "payments"
    SPF_POSTGRES_USER = "payments_username"
    SPF_POSTGRES_PWD = random_password.this.result
  }
}
