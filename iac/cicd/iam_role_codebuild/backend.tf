terraform {
  backend "s3" {
    skip_region_validation = true

    key = "terraform/github/spf/iam_role_codebuild/terraform.tfstate"
  }
}
