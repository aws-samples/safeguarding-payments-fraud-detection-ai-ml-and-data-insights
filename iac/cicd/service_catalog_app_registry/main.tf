# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "aws_servicecatalogappregistry_application" "this" {
  count = trimspace(var.app_name) != "" ? 1 : 0
  name  = var.app_name
}
