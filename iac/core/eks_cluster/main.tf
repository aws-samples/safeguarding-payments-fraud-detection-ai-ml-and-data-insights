# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "aws_eks_cluster" "this" {
  name     = format("%s-%s-%s", var.q.name, data.aws_region.this.name, local.spf_gid)
  role_arn = data.terraform_remote_state.iam.outputs.arn
  version  = var.q.version

  enabled_cluster_log_types = split(",", var.q.log_types)

  access_config {
    authentication_mode                         = var.q.auth_mode
    bootstrap_cluster_creator_admin_permissions = var.q.admin
  }

  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = "172.20.0.0/16"
  }

  vpc_config {
    subnet_ids              = data.terraform_remote_state.subnet.outputs.igw_subnet_ids
    security_group_ids      = [data.terraform_remote_state.sg.outputs.id]
    endpoint_public_access  = var.q.public
    endpoint_private_access = var.q.private
  }
}

resource "aws_eks_addon" "this" {
  count        = length(split(",", var.q.addons))
  cluster_name = aws_eks_cluster.this.name
  addon_name   = element(split(",", var.q.addons), count.index)
}

resource "aws_eks_access_entry" "this" {
  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = data.terraform_remote_state.iam.outputs.arn
  kubernetes_groups = var.q.groups != "" ? split(",", var.q.groups) : null
  type              = var.q.entry_type
}

resource "aws_eks_access_policy_association" "this" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = data.terraform_remote_state.iam.outputs.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type       = var.q.access_type
    namespaces = var.q.namespaces != "" ? split(",", var.q.namespaces) : null
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = format("/aws/eks/%s/cluster", aws_eks_cluster.this.name)
  retention_in_days = var.q.retention
}
