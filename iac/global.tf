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
}

variable "eks_cluster_name" {
  type    = string
  default = ""
}

variable "eks_node_type" {
  type    = string
  default = "fargate"
  validation {
    condition     = contains(["fargate", "eks-managed", "self-managed"], var.eks_node_type)
    error_message = "Valid values: fargate, eks-managed, self-managed"
  }
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "vpce_mapping" {
  type    = string
  default = ""
  # default = "{{gateway_name}},{{gateway_name}}:{{interface_name}},{{interface_name}}"
}

variable "subnets_igw_create" {
  type    = bool
  default = false
}

variable "subnets_igw_mapping" {
  type    = string
  default = ""
  # default = "{{availability_zone_id}}:{{availability_zone_cidr}},{{availability_zone_id}}:{{availability_zone_cidr}}"
}

variable "subnets_nat_create" {
  type    = bool
  default = false
}

variable "subnets_nat_mapping" {
  type    = string
  default = ""
  # default = "{{availability_zone_id}}:{{availability_zone_cidr}},{{availability_zone_id}}:{{availability_zone_cidr}}"
}

variable "subnets_cagw_create" {
  type    = bool
  default = false
}

variable "subnets_cagw_mapping" {
  type    = string
  default = ""
  # default = "{{wavelength_zone_id}}:{{wavelength_zone_cidr}},{{wavelength_zone_id}}:{{wavelength_zone_cidr}}"
}
