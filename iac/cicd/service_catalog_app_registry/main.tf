# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "aws_servicecatalogappregistry_application" "this" {
  name        = var.q.name
  description = var.q.description
}
