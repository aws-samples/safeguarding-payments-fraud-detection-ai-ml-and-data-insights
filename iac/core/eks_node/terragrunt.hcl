# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

dependency "eks" {
  config_path  = "../eks_cluster"
  skip_outputs = true
}

dependency "iam" {
  config_path  = "../iam_role_node"
  skip_outputs = true
}

dependency "subnet" {
  config_path  = "../vpc_subnet"
  skip_outputs = true
}

dependency "s3" {
  config_path  = "../s3_runtime"
  skip_outputs = true
}
