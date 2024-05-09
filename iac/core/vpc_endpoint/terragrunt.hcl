# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

dependency "sg" {
  config_path  = "../security_group"
  skip_outputs = true
}

dependency "subnet" {
  config_path  = "../vpc_subnet"
  skip_outputs = true
}
