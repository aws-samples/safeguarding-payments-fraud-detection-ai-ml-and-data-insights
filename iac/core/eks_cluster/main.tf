# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "aws_eks_cluster" "this" {
  name     = local.name
  role_arn = data.terraform_remote_state.iam_cluster.outputs.arn
  version  = var.q.version

  enabled_cluster_log_types = split(",", var.q.log_types)

  access_config {
    authentication_mode                         = var.q.auth_mode
    bootstrap_cluster_creator_admin_permissions = var.q.admin
  }

  kubernetes_network_config {
    ip_family         = var.q.ip_family
    service_ipv4_cidr = var.q.ipv4_cidr
    service_ipv6_cidr = var.q.ipv6_cidr
  }

  vpc_config {
    subnet_ids              = data.terraform_remote_state.subnet.outputs.igw_subnet_ids
    security_group_ids      = [data.terraform_remote_state.sg.outputs.id]
    endpoint_public_access  = var.q.public
    endpoint_private_access = var.q.private
  }
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = [data.aws_service_principal.this.name]
  thumbprint_list = [data.tls_certificate.this.certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.this.identity.0.oidc.0.issuer

  tags = {
    "alpha.eksctl.io/cluster-name"   = aws_eks_cluster.this.name
    "alpha.eksctl.io/eksctl-version" = var.q.eksctl_version
  }
}

resource "aws_eks_identity_provider_config" "this" {
  cluster_name = aws_eks_cluster.this.name

  oidc {
    client_id                     = substr(aws_iam_openid_connect_provider.this.url, -32, -1)
    identity_provider_config_name = local.name
    issuer_url                    = format("https://%s", aws_iam_openid_connect_provider.this.url)
  }
}

resource "aws_eks_access_entry" "this" {
  count             = local.roles == [] ? 0 : length(local.roles)
  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = format(
    "arn:%s:iam::%s:role/%s",
    data.aws_partition.this.partition,
    data.aws_caller_identity.this.account_id,
    element(local.roles, count.index)
  )
  kubernetes_groups = trimspace(var.q.groups) != "" ? split(",", var.q.groups) : null
  type              = var.q.entry_type
}

resource "aws_eks_access_policy_association" "this" {
  count         = local.roles == [] ? 0 : length(local.roles)
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = format(
    "arn:%s:iam::%s:role/%s",
    data.aws_partition.this.partition,
    data.aws_caller_identity.this.account_id,
    element(local.roles, count.index)
  )
  policy_arn    = format(
    "arn:%s:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy",
    data.aws_partition.this.partition
  )

  access_scope {
    type       = var.q.access_type
    namespaces = trimspace(var.q.namespaces) != "" ? split(",", var.q.namespaces) : null
  }
}
