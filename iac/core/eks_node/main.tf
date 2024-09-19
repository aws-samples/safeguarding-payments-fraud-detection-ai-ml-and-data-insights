# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "aws_eks_fargate_profile" "this" {
  count                  = var.spf_eks_node_type == "fargate" ? length(local.namespaces) : 0
  cluster_name           = data.terraform_remote_state.eks.outputs.id
  pod_execution_role_arn = data.terraform_remote_state.iam_fargate.outputs.arn
  fargate_profile_name   = element(local.namespaces, count.index)
  subnet_ids             = slice(data.terraform_remote_state.subnet.outputs.nat_subnet_ids, 0, var.q.desired_size % 3)

  selector {
    namespace = element(local.namespaces, count.index)
  }
}

resource "aws_eks_node_group" "this" {
  count           = var.spf_eks_node_type == "eks-managed" ? 1 : 0
  cluster_name    = data.terraform_remote_state.eks.outputs.id
  node_group_name = format("%s-%s-%s", var.q.name, data.aws_region.this.name, local.spf_gid)
  node_role_arn   = data.terraform_remote_state.iam_node.outputs.arn
  subnet_ids      = local.subnet_ids

  ami_type        = var.spf_eks_node_arch == "arm" ? "AL2_ARM_64" : "AL2_x86_64"
  capacity_type   = var.q.capacity_type
  instance_types  = split(",", try(trimspace(var.spf_eks_node_ec2), "") != "" ? var.spf_eks_node_ec2 : var.q.instance_types)
  disk_size       = var.q.disk_size
  labels          = local.labels
  release_version = var.q.release_version
  version         = var.q.version

  scaling_config {
    desired_size = var.q.desired_size
    min_size     = var.q.min_size
    max_size     = var.q.max_size
  }

  update_config {
    max_unavailable            = var.q.max_unavailable
    max_unavailable_percentage = var.q.max_percentage
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

module "self_managed_node_group" {
  count   = var.spf_eks_node_type == "self-managed" ? 1 : 0
  source  = "terraform-aws-modules/eks/aws//modules/self-managed-node-group"
  version = "20.19.0"

  name                 = format("%s-%s-%s", var.q.name, data.aws_region.this.name, local.spf_gid)
  cluster_name         = data.terraform_remote_state.eks.outputs.id
  cluster_version      = data.terraform_remote_state.eks.outputs.version
  cluster_endpoint     = data.terraform_remote_state.eks.outputs.endpoint
  cluster_auth_base64  = data.terraform_remote_state.eks.outputs.certificate_authority
  cluster_service_cidr = data.terraform_remote_state.eks.outputs.service_ipv4_cidr
  bootstrap_extra_args = format("--dns-cluster-ip %s", cidrhost(data.terraform_remote_state.eks.outputs.service_ipv4_cidr, 10))

  iam_role_arn             = data.terraform_remote_state.iam_node.outputs.arn
  iam_instance_profile_arn = data.terraform_remote_state.iam_node.outputs.profile_arn

  subnet_ids = local.subnet_ids
  vpc_security_group_ids = concat(
    [data.terraform_remote_state.eks.outputs.cluster_security_group_id],
    split(",", data.terraform_remote_state.eks.outputs.node_security_group_ids)
  )
  instance_type = (
    element(split(",", try(trimspace(var.spf_eks_node_ec2), "") != ""
    ? var.spf_eks_node_ec2 : var.q.instance_types), 0)
  )

  desired_size                = var.q.desired_size
  min_size                    = var.q.min_size
  max_size                    = var.q.max_size
  create_launch_template      = true
  create_autoscaling_group    = true
  create_access_entry         = true
  create_iam_instance_profile = false
  ebs_optimized               = true
  enable_monitoring           = true

  block_device_mappings = {
    xvda = {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = var.q.disk_size
        volume_type           = try(trimspace(var.spf_eks_node_ebs), "") != "" ? var.spf_eks_node_ebs : var.q.disk_type
        delete_on_termination = true
        encrypted             = true
        kms_key_id            = element(module.ebs_kms_key.*.key_arn, 0)
      }
    }
  }

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "disabled"
  }
}

module "ebs_kms_key" {
  count   = var.spf_eks_node_type == "self-managed" ? 1 : 0
  source  = "terraform-aws-modules/kms/aws"
  version = "3.1.0"

  description = var.q.description
  aliases     = [format("eks/%s-%s-%s/ebs", var.q.name, data.aws_region.this.name, local.spf_gid)]

  key_administrators = [
    data.terraform_remote_state.iam_node.outputs.arn, format(
      "arn:%s:iam::%s:root",
      data.aws_partition.this.partition,
      data.aws_caller_identity.this.account_id
    )
  ]

  key_service_roles_for_autoscaling = [
    data.terraform_remote_state.iam_node.outputs.arn,
    format(
      "arn:%s:iam::%s:role/aws-service-role/%s/AWSServiceRoleForAutoScaling",
      data.aws_partition.this.partition,
      data.aws_caller_identity.this.account_id,
      data.aws_service_principal.this.name
    ),
  ]
}

resource "aws_eks_addon" "this" {
  count         = length(split(",", var.q.addons))
  cluster_name  = data.terraform_remote_state.eks.outputs.id
  addon_name    = element(split(",", var.q.addons), count.index)
  addon_version = element(split(",", var.q.addons_version), count.index)
  service_account_role_arn = (
    contains(split(",", var.q.addons_sa_role), element(split(",", var.q.addons), count.index))
    ? data.terraform_remote_state.iam_k8s.outputs.arn : null
  )
  resolve_conflicts_on_create = var.q.addons_create
  resolve_conflicts_on_update = var.q.addons_update
  depends_on                  = [aws_eks_fargate_profile.this, aws_eks_node_group.this, module.self_managed_node_group]
}
