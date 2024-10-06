# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "aws_glue_catalog_table" "this" {
  name          = var.q.name
  database_name = data.terraform_remote_state.glue.outputs.name
  owner         = var.q.owner
  parameters    = var.params
  table_type    = var.q.type

  dynamic "partition_keys" {
    for_each = local.partition_keys
    content {
      name = partition_keys.value.name
      type = partition_keys.value.type
    }
  }

  storage_descriptor {
    compressed                = var.q.compressed
    input_format              = var.q.input
    location                  = format("s3://%s/%s/", data.terraform_remote_state.s3.outputs.id, var.q.name)
    number_of_buckets         = var.q.number
    output_format             = var.q.output
    parameters                = var.params
    stored_as_sub_directories = var.q.stored

    dynamic "columns" {
      for_each = local.columns
      content {
        name = columns.value.name
        type = columns.value.type
      }
    }

    ser_de_info {
      parameters = {
        "quoteChar"     = var.q.quote_char
        "separatorChar" = var.q.separator
      }
      serialization_library = var.q.serde
    }
  }
}
