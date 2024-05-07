# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

dependency "s3" {
  config_path  = "../s3_runtime"
  mock_outputs = {
    region    = "us-east-1"
    role_name = "spf-cicd-assume-role"
  }

  mock_outputs_merge_with_state           = true
  mock_outputs_allowed_terraform_commands = ["init", "plan", "apply", "destroy", "validate"]
}

inputs = {
  SPF_REGION    = dependency.s3.outputs.region
  SPF_ROLE_NAME = dependency.s3.outputs.role_name
}

terraform {
  after_hook "after_hook" {
    commands     = ["apply"]
    execute      = ["${find_in_parent_folders("bin")}/docker.sh", "-q", "spf-fraud"]
    run_on_error = false
  }
}
