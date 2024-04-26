terraform {
  backend "s3" {
    skip_region_validation = true

    key = "terraform/github/spf/codebuild_project/terraform.tfstate"
  }
}
