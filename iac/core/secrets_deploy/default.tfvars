# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

q = {
  name        = "spf-secrets-deploy"
  description = "SPF SECRETS DEPLOY"
  days        = 0
  length      = 16
  special     = true
  override    = "_%@"
  dbhost      = "localhost"
  dbname      = "payments"
  dbuser      = "payments"
  dbport      = "5432"
  srvport     = "35432"
  srvname     = "postgres"
  srvprefix   = "spf-app-postgres"
}
