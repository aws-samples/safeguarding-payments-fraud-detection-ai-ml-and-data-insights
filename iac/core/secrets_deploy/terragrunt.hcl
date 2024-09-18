# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

dependency "eks" {
  config_path  = "../eks_node"
  skip_outputs = true
}

dependency "iam" {
  config_path  = "../iam_role_kubernetes"
  skip_outputs = true
}

dependency "s3" {
  config_path  = "../s3_runtime"
  skip_outputs = true
}
