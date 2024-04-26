terraform {
  backend "s3" {
    skip_region_validation = true

    key = "terraform/github/spf/ecr_fraud/terraform.tfstate"
  }
}
