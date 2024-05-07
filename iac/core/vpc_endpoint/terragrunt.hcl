# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

dependency "eks" {
  config_path  = "../eks_cluster"
  skip_outputs = true
}

dependency "sg" {
  config_path  = "../security_group"
  skip_outputs = true
}
