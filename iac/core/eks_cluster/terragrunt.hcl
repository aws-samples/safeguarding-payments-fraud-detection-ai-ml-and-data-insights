# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

dependency "iam" {
  config_path  = "../iam_role_eks"
  skip_outputs = true
}

dependency "sg" {
  config_path  = "../security_group"
  skip_outputs = true
}

dependency "s3" {
  config_path  = "../s3_runtime"
  skip_outputs = true
}
