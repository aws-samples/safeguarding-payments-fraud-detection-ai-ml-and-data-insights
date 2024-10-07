# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "aws_glue_catalog_database" "this" {
  name = replace(var.q.name, "-", "_")
}
