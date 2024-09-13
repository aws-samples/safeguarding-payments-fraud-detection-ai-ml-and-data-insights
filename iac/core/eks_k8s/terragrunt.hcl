# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

dependency "eks_cluster" {
  config_path  = "../eks_cluster"
  skip_outputs = true
}

dependency "eks_node" {
  config_path  = "../eks_node"
  skip_outputs = true
}

dependency "iam" {
  config_path  = "../iam_role_kubernetes"
  skip_outputs = true
}
