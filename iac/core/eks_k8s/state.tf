# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "uid" {
  value = kubernetes_service_account.this.uid
}
