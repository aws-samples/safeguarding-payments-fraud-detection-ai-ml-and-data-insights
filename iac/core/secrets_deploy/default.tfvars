# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

q = {
  name        = "spf-secrets-deploy"
  description = "SPF SECRETS DEPLOY"
  days        = 0
  length      = 16
  special     = true
  override    = "!"
  dbhost      = "localhost"
  dbname      = "transactions"
  dbuser      = "postgres"
  dbport      = "5432"
  s3user      = "minioadmin"
  srvport     = "5432"
  srvname     = "postgres"
  srvprefix   = "spf-app-postgres"
}
