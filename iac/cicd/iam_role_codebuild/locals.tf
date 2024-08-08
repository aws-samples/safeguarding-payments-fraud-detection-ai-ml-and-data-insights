# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  spf_gid = (var.spf_gid == null ? data.terraform_remote_state.iam.outputs.spf_gid : var.spf_gid)
  statements = [
    {
      actions = "codebuild:CreateReportGroup,codebuild:CreateReport,codebuild:UpdateReport,codebuild:BatchPutTestCases,codebuild:BatchPutCodeCoverages"
      resources = format(
        "arn:%s:codebuild:*:%s:report-group/spf-*",
        data.aws_partition.this.partition,
        data.aws_caller_identity.this.account_id
      )
    },
    {
      actions = "logs:CreateLogGroup,logs:CreateLogStream,logs:PutLogEvents"
      resources = format(
        "arn:%s:logs:*:%s:log-group:/aws/codebuild/spf-*",
        data.aws_partition.this.partition,
        data.aws_caller_identity.this.account_id
      )
    },
    {
      actions = "s3:GetBucket*,s3:ListBucket*"
      resources = format(
        "arn:%s:s3:::%s",
        data.aws_partition.this.partition,
        var.backend_bucket[data.aws_region.this.name]
      )
    },
    {
      actions = "s3:GetObject*,s3:PutObject*"
      resources = format(
        "arn:%s:s3:::%s/*",
        data.aws_partition.this.partition,
        var.backend_bucket[data.aws_region.this.name]
      )
    },
  ]
}
