# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  spf_gid = (var.spf_gid == null ? data.terraform_remote_state.s3.outputs.spf_gid : var.spf_gid)
  suffix  = format("%s-%s", data.aws_region.this.name, local.spf_gid)
  policies = [
    aws_iam_policy.this.arn,
    format("arn:%s:iam::aws:policy/AmazonDynamoDBFullAccess", data.aws_partition.this.partition),
    format("arn:%s:iam::aws:policy/AmazonS3FullAccess", data.aws_partition.this.partition),
    format("arn:%s:iam::aws:policy/AmazonSSMFullAccess", data.aws_partition.this.partition),
  ]
  service_accounts = [
    "system:serviceaccount:kube-system:ebs-csi-controller-sa",
    format("system:serviceaccount:spf-app-anomaly-detector-%s:service-account", local.suffix),
    format("system:serviceaccount:spf-app-data-collector-%s:service-account", local.suffix),
    format("system:serviceaccount:spf-app-postgres-%s:service-account", local.suffix),
    format("system:serviceaccount:spf-app-minio-%s:service-account", local.suffix),
  ]
}
