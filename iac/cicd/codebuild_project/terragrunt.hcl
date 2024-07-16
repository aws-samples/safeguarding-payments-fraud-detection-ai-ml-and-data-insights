# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

dependency "app_registry" {
  config_path  = "../service_catalog_app_registry"
  skip_outputs = true
}

dependency "iam_assume" {
  config_path  = "../iam_role_assume"
  skip_outputs = true
}

dependency "iam_codebuild" {
  config_path  = "../iam_role_codebuild"
  skip_outputs = true
}
