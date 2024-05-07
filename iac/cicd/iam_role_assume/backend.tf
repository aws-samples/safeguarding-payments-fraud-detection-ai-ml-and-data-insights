# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

terraform {
  backend "s3" {
    skip_region_validation = true

    key = "terraform/github/spf/iam_role_assume/terraform.tfstate"
  }
}
