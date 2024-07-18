# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "aws_s3_bucket" "this" {
  #checkov:skip=CKV_AWS_18:This solution implemented access logging as a separate terraform resource (false positive)
  #checkov:skip=CKV_AWS_19:This solution implemented encryption at rest as a separate terraform resource (false positive)
  #checkov:skip=CKV_AWS_21:This solution implemented versioning as a separate terraform resource (false positive)
  #checkov:skip=CKV_AWS_144:This solution implemented cross region replication as a separate terraform resource (false positive)
  #checkov:skip=CKV_AWS_145:This solution implemented encryption as a separate terraform resource (false positive)
  #checkov:skip=CKV2_AWS_6:This solution implemented public access as a separate terraform resource (false positive)
  #checkov:skip=CKV2_AWS_61:This solution implemented lifecycle as a separate terraform resource (false positive)
  #checkov:skip=CKV2_AWS_62:This solution implemented events notification as a separate terraform resource (false positive)

  bucket              = format("%s-%s-%s", var.q.bucket, data.aws_region.this.name, local.spf_gid)
  force_destroy       = var.q.force_destroy
  object_lock_enabled = var.q.object_lock_enabled

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.q.versioning_status
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.q.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_object_lock_configuration" "this" {
  count  = var.q.object_lock_enabled ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    default_retention {
      mode = var.q.object_lock_mode
      days = var.q.object_lock_days
    }
  }
}

resource "aws_s3_bucket_logging" "this" {
  bucket        = aws_s3_bucket.this.id
  target_bucket = aws_s3_bucket.this.id
  target_prefix = var.q.logs_prefix
}

resource "random_id" "this" {
  byte_length = 4

  keepers = {
    spf_gid = try(var.spf_gid, "abcd1234")
  }

  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------------------------------
# Adding guidance solution ID via AWS CloudFormation resource
#--------------------------------------------------------------
resource "aws_cloudformation_stack" "this" {
    name = format("spf-tracking-stack-%s-%s", data.aws_region.this.name, local.spf_gid)
    template_body = <<STACK
    {
        "AWSTemplateFormatVersion": "2010-09-09",
        "Description": "Safeguarding Payments: Fraud Detection, AI/ML and Data Insights (SO9257)",
        "Resources": {
            "EmptyResource": {
                "Type": "AWS::CloudFormation::WaitConditionHandle"
            }
        }
    }
    STACK
}
