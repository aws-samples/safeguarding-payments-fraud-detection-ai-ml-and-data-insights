# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

data "aws_region" "this" {}
data "aws_caller_identity" "this" {}

provider "aws" {
  allowed_account_ids    = try(split(",", var.account), null)
  skip_region_validation = true

  default_tags {
    tags = {
      project        = "safeguarding-payments"
      environment    = "default"
      contact        = "github.com/eistrati"
      globalId       = var.spf_gid
      awsApplication = try(var.app_arn, null)
    }
  }
}

terraform {
  required_version = ">= 1.2.0, <1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.48.0"
    }
  }
}

variable "spf_gid" {
  type    = string
  default = null
}

variable "backend_bucket" {
  type = map(string)
  default = {
    "us-east-1" = "spf-backend-us-east-1"
    "us-west-2" = "spf-backend-us-west-2"
  }
}

variable "backend_pattern" {
  type    = string
  default = "terraform/github/spf/%s/terraform.tfstate"
}

variable "account" {
  type    = string
  default = null
}

variable "app_arn" {
  type    = string
  default = ""
  # default = ""
}

variable "vpc_id" {
  type    = string
  default = ""
  # default = "vpc-1234567890abcdef"
}

variable "vpce_services" {
  type    = string
  default = ""
  # default = "dynamodb,s3:ec2,ec2messages,ecr.api,ecr.dkr,eks,kms,logs,s3,sts"
}

variable "vpc_subnets_create" {
  type    = bool
  default = false
}

variable "vpc_subnets_source" {
  type    = string
  default = "availability_zones"

  validation {
    condition     = contains(["availability_zones", "local_zones", "outpost_zones", "wavelength_zones"], var.vpc_subnets_source)
    error_message = "Valid values: availability_zones, local_zones, outpost_zones, wavelength_zones"
  }
}

variable "vpc_subnets_azs" {
  type    = string
  default = ""
  # default = "use1-az1:172.31.0.0/20,use1-az2:172.31.80.0/20,use1-az3:172.31.48.0/20"
}

variable "vpc_subnets_lzs" {
  type    = string
  default = ""
  # default = "{{local_zone_id}}:{{local_zone_cidr}},{{local_zone_id}}:{{local_zone_cidr}}"
}

variable "vpc_subnets_ozs" {
  type    = string
  default = ""
  # default = "{{outpost_zone_id}}:{{outpost_zone_cidr}},{{outpost_zone_id}}:{{outpost_zone_cidr}}"
}

variable "vpc_subnets_wzs" {
  type    = string
  default = ""
  # default = "use1-wl1-nyc-wlz1:10.0.100.0/24,use1-wl1-bos-wlz1:10.0.110.0/24"
}
