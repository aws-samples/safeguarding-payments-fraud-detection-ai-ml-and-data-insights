# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

q = {
  name                 = "spf-fraud"
  force_delete         = true
  image_tag_mutability = "MUTABLE"
  encryption_type      = "KMS"
  scan_on_push         = true
}
