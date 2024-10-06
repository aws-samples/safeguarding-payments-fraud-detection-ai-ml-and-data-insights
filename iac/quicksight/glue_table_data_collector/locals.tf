# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  partition_keys = [
    {
      name = "partition_0"
      type = "string"
    },
    {
      name = "partition_1"
      type = "string"
    },
    {
      name = "partition_2"
      type = "string"
    },
    {
      name = "partition_3"
      type = "string"
    },
    {
      name = "partition_4"
      type = "string"
    },
    {
      name = "partition_5"
      type = "string"
    },
  ]
  columns = [
    {
      name = "event_label"
      type = "bigint"
    },
    {
      name = "event_timestamp"
      type = "string"
    },
    {
      name = "label_timestamp"
      type = "string"
    },
    {
      name = "event_id"
      type = "string"
    },
    {
      name = "entity_type"
      type = "string"
    },
    {
      name = "entity_id"
      type = "string"
    },
    {
      name = "card_bin"
      type = "bigint"
    },
    {
      name = "customer_name"
      type = "string"
    },
    {
      name = "billing_street"
      type = "string"
    },
    {
      name = "billing_city"
      type = "string"
    },
    {
      name = "billing_state"
      type = "string"
    },
    {
      name = "billing_zip"
      type = "bigint"
    },
    {
      name = "billing_latitude"
      type = "double"
    },
    {
      name = "billing_longitude"
      type = "double"
    },
    {
      name = "billing_country"
      type = "string"
    },
    {
      name = "customer_job"
      type = "string"
    },
    {
      name = "ip_address"
      type = "string"
    },
    {
      name = "customer_email"
      type = "string"
    },
    {
      name = "billing_phone"
      type = "string"
    },
    {
      name = "user_agent"
      type = "string"
    },
    {
      name = "product_category"
      type = "string"
    },
    {
      name = "order_price"
      type = "double"
    },
    {
      name = "payment_currency"
      type = "string"
    },
    {
      name = "merchant"
      type = "string"
    },
  ]
}
