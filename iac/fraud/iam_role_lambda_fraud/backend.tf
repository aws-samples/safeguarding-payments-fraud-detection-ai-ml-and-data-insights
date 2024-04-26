terraform {
  backend "s3" {
    skip_region_validation = true

    key = "terraform/github/spf/iam_role_lambda_fraud/terraform.tfstate"
  }
}
