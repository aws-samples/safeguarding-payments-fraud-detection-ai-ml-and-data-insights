# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

dependency "app_registry" {
  config_path  = "../service_catalog_app_registry"
  skip_outputs = true
}

dependency "iam" {
  config_path  = "../iam_role_assume"
  skip_outputs = true
}

terraform {
  after_hook "after_hook" {
    commands     = ["apply"]
    execute      = ["sh", "-c", "aws iam create-service-linked-role --aws-service-name autoscaling.amazonaws.com || echo '[DEBUG] ^^ ignoring error, all good'"]
    run_on_error = false
  }
}
