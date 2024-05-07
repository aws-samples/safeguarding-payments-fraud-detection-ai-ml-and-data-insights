# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

q = {
  name      = "spf-eks-cluster"
  version   = "1.29"
  public    = true
  private   = true
  admin     = true
  auth_mode = "API_AND_CONFIG_MAP"
  addons    = "vpc-cni,coredns,kube-proxy,eks-pod-identity-agent"
  log_types = "api,audit,authenticator,controllerManager,scheduler"
  retention = 7
}
