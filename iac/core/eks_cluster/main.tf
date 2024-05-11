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

resource "aws_eks_fargate_profile" "this" {
  cluster_name           = aws_eks_cluster.this.name
  pod_execution_role_arn = data.terraform_remote_state.iam_fargate.outputs.arn
  fargate_profile_name   = var.q.namespace
  subnet_ids             = data.terraform_remote_state.subnet.outputs.nat_subnet_ids

  selector {
    namespace = var.q.namespace
  }
}

resource "aws_eks_addon" "this" {
  count                       = length(split(",", var.q.addons))
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = element(split(",", var.q.addons), count.index)
  addon_version               = element(split(",", var.q.addons_version), count.index)
  resolve_conflicts_on_create = var.q.addons_create
  resolve_conflicts_on_update = var.q.addons_update
  depends_on                  = [aws_eks_fargate_profile.this]
}

resource "aws_eks_access_entry" "this" {
  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = data.terraform_remote_state.iam_cluster.outputs.arn
  kubernetes_groups = var.q.groups != "" ? split(",", var.q.groups) : null
  type              = var.q.entry_type
}

resource "aws_eks_access_policy_association" "this" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = data.terraform_remote_state.iam_cluster.outputs.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type       = var.q.access_type
    namespaces = var.q.namespaces != "" ? split(",", var.q.namespaces) : null
  }
}
