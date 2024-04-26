locals {
  spf_gid = data.terraform_remote_state.s3.outputs.spf_gid
  statements = [
    {
      actions = "cloudwatch:*"
      resources = format(
        "arn:aws:cloudwatch:*:%s:insight-rule/DynamoDBContributorInsights*",
        data.aws_caller_identity.this.account_id
      )
    },
    {
      actions = "logs:*,tag:GetResources"
      resources = format(
        "arn:aws:logs:*:%s:log-group:/aws/lambda/spf-*,arn:aws:logs:*:%s:log-group:API-Gateway-*",
        data.aws_caller_identity.this.account_id, data.aws_caller_identity.this.account_id
      )
    },
    {
      actions = "dynamodb:*,application-autoscaling:*,tag:GetResources"
      resources = format(
        "arn:aws:dynamodb:*:%s:table/spf-*,arn:aws:dynamodb::%s:global-table/spf-*",
        data.aws_caller_identity.this.account_id, data.aws_caller_identity.this.account_id
      )
    },
    {
      actions = "kms:DescribeKey,kms:ListAliases,kms:Decrypt"
      resources = format(
        "arn:aws:kms:*:%s:key/*",
        data.aws_caller_identity.this.account_id
      )
    },
    {
      actions = "lambda:InvokeFunction,tag:GetResources"
      resources = format(
        "arn:aws:lambda:*:%s:function:spf-*",
        data.aws_caller_identity.this.account_id
      )
    },
    {
      actions = "s3:*,s3-object-lambda:*,tag:GetResources"
      resources = format(
        "%s,%s/*",
        data.terraform_remote_state.s3.outputs.arn,
        data.terraform_remote_state.s3.outputs.arn
      )
    },
    {
      actions = "sns:*,tag:GetResources"
      resources = format(
        "arn:aws:sns:*:%s:spf-*",
        data.aws_caller_identity.this.account_id
      )
    },
  ]
}
