# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "arn" {
  value = aws_s3_bucket.this.arn
}

output "id" {
  value = aws_s3_bucket.this.id
}

output "bucket_domain_name" {
  value = aws_s3_bucket.this.bucket_domain_name
}

output "domain" {
  value = aws_s3_bucket.this.bucket_regional_domain_name
}

output "hosted_zone_id" {
  value = aws_s3_bucket.this.hosted_zone_id
}

output "region" {
  value = aws_s3_bucket.this.region
}

output "region2" {
  value = (
    aws_s3_bucket.this.region == element(keys(var.spf_backend_bucket), 0)
    ? element(keys(var.spf_backend_bucket), 1) : element(keys(var.spf_backend_bucket), 0)
  )
}

output "role_name" {
  value = format("%s-%s-%s", var.q.assume_role_name, aws_s3_bucket.this.region, local.spf_gid)
}

output "spf_gid" {
  value = local.spf_gid
}
