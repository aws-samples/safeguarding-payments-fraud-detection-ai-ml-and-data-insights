# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

apiVersion: v1
kind: ConfigMap
metadata:
  namespace: {{SPF_ECR_NAME}}
  name: data-collector-config
  creationTimestamp: null
data:
  file_data_extract_folder_in_s3: "file_extract"
  file_line_number_to_read_from: "1"
  files_location_in_s3: "raw_payment_request_files"
  max_lines_to_read: "10000"
  payment_data: "transaction_data_100K_full.csv"
  s3_bucket: "{{SPF_S3_BUCKET}}"
