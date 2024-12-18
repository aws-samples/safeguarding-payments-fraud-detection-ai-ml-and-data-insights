# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "aws_servicecatalogappregistry_application" "this" {
  count = try(trimspace(var.spf_app_name), "") != "" ? 1 : 0
  name  = var.spf_app_name
}
