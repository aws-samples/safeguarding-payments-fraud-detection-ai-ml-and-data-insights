# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

q = {
  name           = "spf-eks-cluster"
  version        = "1.31"
  public         = true
  private        = true
  admin          = true
  ip_family      = "ipv4"
  ipv4_cidr      = "172.20.0.0/16"
  ipv6_cidr      = null
  auth_mode      = "API_AND_CONFIG_MAP"
  eksctl_version = "0.176.0-dev+5b33f073a.2024-04-25T09:34:19Z"
  entry_type     = "STANDARD"
  groups         = ""
  access_type    = "cluster"
  namespaces     = ""
  log_types      = "api,audit,authenticator,controllerManager,scheduler"
}
