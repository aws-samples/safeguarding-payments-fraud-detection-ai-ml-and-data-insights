terraform {
  backend "s3" {
    skip_region_validation = true

    key = "terraform/github/spf/s3_runtime/terraform.tfstate"
  }
}
