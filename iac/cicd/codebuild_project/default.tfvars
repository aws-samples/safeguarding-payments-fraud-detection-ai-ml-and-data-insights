# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

q = {
  name                        = "spf-cicd-pipeline"
  description                 = "SPF CICD PIPELINE"
  build_timeout               = 60
  file                        = "buildspec.yml.tpl"
  compute_type                = "BUILD_GENERAL1_LARGE"
  type                        = "LINUX_CONTAINER"
  image                       = "aws/codebuild/standard:7.0"
  image_pull_credentials_type = "CODEBUILD"
  privileged_mode             = true
  cw_group_name_prefix        = "/aws/codebuild"
  retention_in_days           = 5
  skip_destroy                = true
  s3_logs_status              = "ENABLED"
  s3_logs_location            = "codebuild"
  s3_cache_location           = "cache"
}
