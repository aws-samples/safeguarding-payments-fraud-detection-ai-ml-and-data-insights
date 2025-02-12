# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

q = {
  name            = "spf-eks"
  description     = "SPF EKS NODE"
  fargate_names   = "kube-node-lease,kube-public,kube-system"
  app_namespaces  = "spf-app-data-collector,spf-app-fraud,spf-app-postgres"
  capacity_type   = "ON_DEMAND"
  instance_types  = "t3.medium,t3.xlarge"
  disk_type       = "gp2"
  disk_size       = 20
  desired_size    = 2
  min_size        = 2
  max_size        = 2
  max_unavailable = 1
  max_percentage  = null
  labels          = ""
  release_version = null
  version         = null
  addons          = "vpc-cni,kube-proxy,aws-ebs-csi-driver"
  addons_version  = "v1.19.2-eksbuild.1,v1.31.3-eksbuild.2,v1.38.1-eksbuild.2"
  addons_sa_role  = "aws-ebs-csi-driver"
  addons_create   = "OVERWRITE"
  addons_update   = "PRESERVE"
}
