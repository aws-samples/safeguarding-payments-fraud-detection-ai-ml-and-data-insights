# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  spf_gid = (var.spf_gid == null ? data.terraform_remote_state.s3.outputs.spf_gid : var.spf_gid)
  azs = [for i in data.aws_subnet.this : i.availability_zone]
  secret = {
    SPF_DOCKERFILE_DBHOST = var.q.dbhost
    SPF_DOCKERFILE_DBPORT = var.q.dbport
    SPF_DOCKERFILE_DBNAME = var.q.dbname
    SPF_DOCKERFILE_DBUSER = var.q.dbuser
    SPF_DOCKERFILE_DBPASS = base64encode(random_password.db.result)
    SPF_S3_REGION         = data.terraform_remote_state.s3.outputs.region
    SPF_S3_BUCKET         = data.terraform_remote_state.s3.outputs.id
    SPF_S3_ENDPOINT_URL   = try(trimspace(var.spf_s3_endpoint_url), "") != "" ? base64encode(var.spf_s3_endpoint_url) : ""
    SPF_S3_MINIO_USER     = base64encode(var.q.s3user)
    SPF_S3_MINIO_PASS     = base64encode(random_password.s3.result)
    SPF_SERVICE_AZ1       = element(local.azs, 0)
    SPF_SERVICE_AZ2       = element(local.azs, 1)
    SPF_SERVICE_AZ3       = element(local.azs, 2)
    SPF_SERVICE_DBPORT    = var.q.srvport
    SPF_SERVICE_DBNAME    = var.q.srvname
    SPF_SERVICE_NAMESPACE = format("%s-%s-%s", var.q.srvprefix, data.aws_region.this.name, local.spf_gid)
    SPF_SERVICE_PRINCIPAL = data.aws_service_principal.this.name
    SPF_SERVICE_ROLE      = data.terraform_remote_state.iam.outputs.arn
  }
}
