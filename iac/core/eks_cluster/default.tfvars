# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

q = {
  name           = "spf-eks-cluster"
  namespace      = "kube-system"
  version        = "1.29"
  public         = true
  private        = true
  admin          = true
  ip_family      = "ipv4"
  ipv4_cidr      = "172.20.0.0/16"
  ipv6_cidr      = null
  auth_mode      = "API_AND_CONFIG_MAP"
  addons         = "vpc-cni,kube-proxy,eks-pod-identity-agent,coredns"
  addons_version = "v1.18.1-eksbuild.1,v1.29.3-eksbuild.2,v1.2.0-eksbuild.1,v1.11.1-eksbuild.9"
  addons_create  = "OVERWRITE"
  addons_update  = "PRESERVE"
  entry_type     = "STANDARD"
  groups         = ""
  access_type    = "cluster"
  namespaces     = ""
  log_types      = "api,audit,authenticator,controllerManager,scheduler"
}
