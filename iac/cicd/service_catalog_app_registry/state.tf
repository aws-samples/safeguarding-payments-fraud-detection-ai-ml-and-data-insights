# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "arn" {
  value = length(aws_servicecatalogappregistry_application.this.*.arn) > 0 ? element(aws_servicecatalogappregistry_application.this.*.arn, 0) : ""
}

output "id" {
  value = length(aws_servicecatalogappregistry_application.this.*.id) > 0 ? element(aws_servicecatalogappregistry_application.this.*.id, 0) : ""
}

output "tags" {
  value = length(aws_servicecatalogappregistry_application.this.*.application_tag) > 0 ? element(aws_servicecatalogappregistry_application.this.*.application_tag, 0) : ""
}
