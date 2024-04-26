resource "aws_lambda_function" "this" {
  #checkov:skip=CKV_AWS_50:This solution does not require XRay in production (false positive)
  #checkov:skip=CKV_AWS_117:This solution does not support VPC due to container based images (false positive)
  #checkov:skip=CKV_AWS_173:This solution leverages KMS encryption using AWS managed keys instead of CMKs (false positive)
  #checkov:skip=CKV_AWS_272:This solution does not support code signing due to container based images (false positive)

  function_name = format("%s-%s", var.q.name, local.spf_gid)
  description   = var.q.description
  role          = data.terraform_remote_state.iam.outputs.arn
  package_type  = var.q.package_type
  architectures = [var.q.architecture]
  image_uri     = format("%s@%s", data.terraform_remote_state.ecr.outputs.repository_url, data.aws_ecr_image.this.id)
  memory_size   = var.q.memory_size
  timeout       = var.q.timeout
  publish       = var.q.publish

  reserved_concurrent_executions = var.q.reserved

  environment {
    variables = {
      SPF_LOGGING  = var.q.logging
      SPF_GID      = local.spf_gid
      SPF_ACCOUNT  = data.aws_caller_identity.this.account_id
      SPF_REGION   = data.aws_region.this.name
      SPF_FAILOVER = local.region

      SECRETS_MANAGER_TTL = var.q.secrets_manager_ttl
    }
  }

  ephemeral_storage {
    size = var.q.storage_size
  }

  tracing_config {
    mode = var.q.tracing_mode
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "this" {
  #checkov:skip=CKV_AWS_158:This solution leverages CloudWatch logs (false positive)

  name              = format("%s/%s-%s", var.q.cw_group_name_prefix, var.q.name, local.spf_gid)
  retention_in_days = var.q.retention_in_days
  skip_destroy      = var.q.skip_destroy
}
