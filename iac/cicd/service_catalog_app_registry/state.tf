# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "arn" {
  value = aws_servicecatalogappregistry_application.this.arn
}

output "id" {
  value = aws_servicecatalogappregistry_application.this.id
}

output "tags" {
  value = aws_servicecatalogappregistry_application.this.application_tag
}
