# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

q = {
  name       = "anomaly-detector"
  owner      = "owner"
  type       = "EXTERNAL_TABLE"
  compressed = false
  stored     = false
  number     = -1
  input      = "org.apache.hadoop.mapred.TextInputFormat"
  output     = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
  serde      = "org.apache.hadoop.hive.serde2.OpenCSVSerde"
  quote_char = "\""
  separator  = ","
}

params = {
  "CrawlerSchemaDeserializerVersion" = "1.0"
  "CrawlerSchemaSerializerVersion"   = "1.0"
  "UPDATED_BY_CRAWLER"               = "safeguarding-payments"
  "areColumnsQuoted"                 = "true"
  "averageRecordSize"                = "373"
  "classification"                   = "csv"
  "columnsOrdered"                   = "true"
  "compressionType"                  = "none"
  "customSerde"                      = "OpenCSVSerDe"
  "delimiter"                        = ","
  "objectCount"                      = "6"
  "partition_filtering.enabled"      = "true"
  "recordCount"                      = "62421"
  "sizeKey"                          = "23341620"
  "skip.header.line.count"           = "1"
  "typeOfData"                       = "file"
}
