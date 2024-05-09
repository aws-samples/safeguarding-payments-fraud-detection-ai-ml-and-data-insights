# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

q = {
  name        = "spf-eks-cluster"
  version     = "1.29"
  public      = true
  private     = true
  admin       = true
  auth_mode   = "API_AND_CONFIG_MAP"
  addons      = "vpc-cni,kube-proxy,eks-pod-identity-agent,coredns"
  entry_type  = "STANDARD"
  groups      = ""
  access_type = "cluster"
  namespaces  = ""
  log_types   = "api,audit,authenticator,controllerManager,scheduler"
  retention   = 7
}
