# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  spf_gid = (var.spf_gid == null ? data.terraform_remote_state.s3.outputs.spf_gid : var.spf_gid)
  secret  = {
    SPF_DBNAME       = var.q.dbname
    SPF_DBUSER       = var.q.dbuser
    SPF_DBPASS       = base64encode(random_password.this.result)
    SPF_DBPORT       = var.q.dbport
    SPF_SERVICE_PORT = var.q.srvport
    SPF_SERVICE_ROLE = data.terraform_remote_state.iam.outputs.arn
  }
}
