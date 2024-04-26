terraform {
  backend "s3" {
    skip_region_validation = true

    key = "terraform/github/spf/lambda_fraud/terraform.tfstate"
  }
}
