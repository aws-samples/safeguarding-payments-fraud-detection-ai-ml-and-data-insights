# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  gateways   = split(",", element(split(":", try(var.vpce_mapping, ":")), 0))
  interfaces = split(",", element(split(":", try(var.vpce_mapping, ":")), 1))
}
