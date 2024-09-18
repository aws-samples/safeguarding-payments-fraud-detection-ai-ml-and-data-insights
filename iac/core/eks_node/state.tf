# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "eks_mng_arn" {
  value = aws_eks_node_group.this.*.arn
}

output "eks_mng_id" {
  value = aws_eks_node_group.this.*.id
}

output "eks_mng_status" {
  value = aws_eks_node_group.this.*.status
}

output "fargate_mng_arn" {
  value = aws_eks_fargate_profile.this.*.arn
}

output "fargate_mng_id" {
  value = aws_eks_fargate_profile.this.*.id
}

output "fargate_mng_status" {
  value = aws_eks_fargate_profile.this.*.status
}

output "self_mng_image_id" {
  value = module.self_managed_node_group.*.image_id
}

output "self_mng_ags_arn" {
  value = module.self_managed_node_group.*.autoscaling_group_arn
}

output "self_mng_ags_id" {
  value = module.self_managed_node_group.*.autoscaling_group_id
}

output "self_mng_iam_role_arn" {
  value = module.self_managed_node_group.*.iam_role_arn
}

output "self_mng_iam_role_id" {
  value = module.self_managed_node_group.*.iam_role_id
}

output "self_mng_iam_profile_arn" {
  value = module.self_managed_node_group.*.iam_instance_profile_arn
}

output "self_mng_iam_profile_id" {
  value = module.self_managed_node_group.*.iam_instance_profile_id
}

output "self_mng_tpl_arn" {
  value = module.self_managed_node_group.*.launch_template_arn
}

output "self_mng_tpl_id" {
  value = module.self_managed_node_group.*.launch_template_id
}

output "subnet_ids" {
  value = (
    length(aws_eks_fargate_profile.this.*.subnet_ids) > 0
    ? aws_eks_fargate_profile.this.*.subnet_ids : local.subnet_ids
  )
}
