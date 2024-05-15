# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "arn" {
  value = aws_eks_cluster.this.arn
}

output "id" {
  value = aws_eks_cluster.this.id
}

output "cluster_id" {
  value = aws_eks_cluster.this.cluster_id
}

output "created_at" {
  value = aws_eks_cluster.this.created_at
}

output "endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "platform_version" {
  value = aws_eks_cluster.this.platform_version
}

output "version" {
  value = aws_eks_cluster.this.version
}

output "status" {
  value = aws_eks_cluster.this.status
}

output "cluster_security_group_id" {
  value = aws_eks_cluster.this.vpc_config.0.cluster_security_group_id
}

output "node_security_group_ids" {
  value = join(",", aws_eks_cluster.this.vpc_config.0.security_group_ids)
}

output "certificate_authority" {
  value = aws_eks_cluster.this.certificate_authority.0.data
}

output "service_ipv4_cidr" {
  value = aws_eks_cluster.this.kubernetes_network_config.0.service_ipv4_cidr
}

output "service_ipv6_cidr" {
  value = aws_eks_cluster.this.kubernetes_network_config.0.service_ipv6_cidr
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.this.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.this.url
}
