# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

dependency "ecr" {
  config_path  = "../ecr_fraud"
  skip_outputs = true
}

dependency "iam" {
  config_path  = "../iam_role_lambda_fraud"
  skip_outputs = true
}
