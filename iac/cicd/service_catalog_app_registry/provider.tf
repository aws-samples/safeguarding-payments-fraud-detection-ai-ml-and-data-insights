# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

provider "aws" {
  allowed_account_ids    = try(split(",", var.account), null)
  skip_region_validation = true

  default_tags {
    tags = {
      project     = "safeguarding-payments"
      environment = "default"
      contact     = "github.com/eistrati"
      globalId    = var.spf_gid
    }
  }
}

terraform {
  required_version = ">= 1.2.0, <1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.58.0"
    }
  }
}

variable "account" {
  type        = string
  description = "Allowed AWS account ID (or IDs, separated by comma)"
  default     = null
}

variable "spf_gid" {
  type        = string
  description = "Global ID appended to AWS resource names (e.g. abcd1234)"
  default     = ""
}

variable "backend_bucket" {
  type        = map(string)
  description = "S3 bucket for terraform backend in each supported AWS region"
  default = {
    "us-east-1" = "spf-backend-us-east-1"
    "us-west-2" = "spf-backend-us-west-2"
  }
}

variable "backend_pattern" {
  type        = string
  description = "S3 path pattern for terraform backend"
  default     = "terraform/github/spf/%s/terraform.tfstate"
}
