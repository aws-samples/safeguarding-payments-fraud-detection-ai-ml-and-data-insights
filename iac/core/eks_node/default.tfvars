# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

q = {
  name            = "spf-eks"
  description     = "SPF EKS NODE"
  namespaces      = "spf-app-data-collector,spf-app-postgres"
  ami_type        = "AL2_X86_64" # "AL2_ARM_64"
  capacity_type   = "ON_DEMAND"
  instance_types  = "t3.xlarge,t3.medium" # "t4g.medium,t4g.micro"
  disk_size       = 50
  disk_type       = "gp2" # "gp3"
  desired_size    = 1
  min_size        = 1
  max_size        = 2
  max_unavailable = 1
  max_percentage  = null
  labels          = ""
  release_version = null
  version         = null
}
