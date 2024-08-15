# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

provider "aws" {
  allowed_account_ids    = try(split(",", var.spf_account), null)
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
      version = "5.61.0"
    }
  }
}

variable "spf_backend_bucket" {
  type        = map(string)
  description = "S3 bucket for terraform backend in each supported AWS region"
  default = {
    "us-east-1" = "spf-backend-us-east-1"
    "us-west-2" = "spf-backend-us-west-2"
  }
}

variable "spf_backend_pattern" {
  type        = string
  description = "S3 path pattern for terraform backend"
  default     = "terraform/github/spf/%s/terraform.tfstate"
}

variable "spf_gid" {
  type        = string
  description = "Global ID appended to AWS resource names (e.g. abcd1234)"
  default     = ""
}

variable "spf_account" {
  type        = string
  description = "Allowed AWS account ID (or IDs, separated by comma)"
  default     = null
}

variable "spf_app_arn" {
  type        = string
  description = "AWS myApplication ARN (e.g. arn:{{partition}}:resource-groups:{{region_name}}:{{account_id}}:group/{{app_id}})"
  default     = ""
}

variable "spf_app_name" {
  type        = string
  description = "AWS myApplication Name (e.g. spf)"
  default     = ""
}

variable "spf_eks_cluster_name" {
  type        = string
  description = "EKS cluster name (e.g. spf-eks-cluster-us-east-1-abcd1234)"
  default     = ""
}

variable "spf_eks_access_roles" {
  type        = string
  description = "EKS admin roles (e.g. {{role_name1}},{{role_name2}})"
  default     = ""
}

variable "spf_eks_node_type" {
  type        = string
  description = "EKS node type (e.g. eks-managed, or fargate, or self-managed)"
  default     = "self-managed"
  validation {
    condition     = contains(["eks-managed", "fargate", "self-managed"], var.spf_eks_node_type)
    error_message = "Valid values: eks-managed, fargate, self-managed"
  }
}

variable "spf_eks_node_arch" {
  type        = string
  description = "EKS node architecture (e.g. x86, or arm, or amd)"
  default     = "x86"
  validation {
    condition     = contains(["x86", "arm", "amd"], var.spf_eks_node_arch)
    error_message = "Valid values: x86, arm, amd"
  }
}

variable "spf_eks_node_ec2" {
  type        = string
  description = "EKS node family (one or many, separated by comma)"
  default     = "t3.medium,t3.xlarge"
}

variable "spf_eks_node_ebs" {
  type        = string
  description = "EKS node disk (e.g. gp2, or gp3)"
  default     = "gp2"
  validation {
    condition     = contains(["gp2", "gp3"], var.spf_eks_node_ebs)
    error_message = "Valid values: gp2, gp3"
  }
}

variable "spf_s3_endpoint_url" {
  type        = string
  description = "S3 Endpoint URL (used in case of MinIO based deployment)"
  default     = ""
}

variable "spf_vpc_id" {
  type        = string
  description = "VPC ID (must already exist, otherwise reuse the default vpc)"
  default     = ""
}

variable "spf_vpce_mapping" {
  type        = string
  description = "VPC endpoints mapping (e.g. {{interface_name}},{{interface_name}}:{{gateway_name}},{{gateway_name}})"
  default     = ""
}

variable "spf_subnets_igw_create" {
  type        = bool
  description = "Create public subnets (if true, otherwise reuse the existing ones)"
  default     = false
}

variable "spf_subnets_nat_create" {
  type        = bool
  description = "Create private subnets (if true, otherwise reuse the existing ones)"
  default     = false
}

variable "spf_subnets_cagw_create" {
  type        = bool
  description = "Create wavelength subnets (if true, otherwise reuse the existing ones)"
  default     = false
}

variable "spf_subnets_igw_mapping" {
  type        = string
  description = "Public subnets mapping (e.g. {{availability_zone_id}}:{{availability_zone_cidr}},{{local_zone_id}}:{{local_zone_cidr}})"
  default     = ""
}

variable "spf_subnets_nat_mapping" {
  type        = string
  description = "Private subnets mapping (e.g. {{availability_zone_id}}:{{availability_zone_cidr}},{{local_zone_id}}:{{local_zone_cidr}})"
  default     = ""
}

variable "spf_subnets_cagw_mapping" {
  type        = string
  description = "Wavelength subnets mapping (e.g. {{wavelength_zone_id}}:{{wavelength_zone_cidr}},{{wavelength_zone_id}}:{{wavelength_zone_cidr}})"
  default     = ""
}
