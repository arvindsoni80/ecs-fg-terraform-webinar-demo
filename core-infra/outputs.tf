# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
output "cluster_name" {
  value       = module.ecs_cluster.ecs_cluster_name
  description = "ECS cluster name"
}

output "cluster_id" {
  value       = module.ecs_cluster.ecs_cluster_id
  description = "ECS cluster arn"
}

output "cluster_region" {
  value = var.aws_region
}

output "vpc_id" {
  value = module.networking.aws_vpc
}

output "ecs_task_execution_role_arn" {
  value       = module.ecs_task_execution_role.arn_role
  description = "ECS task execution role arn"
}

output "ecs_task_execution_role_name" {
  value       = module.ecs_task_execution_role.name_role
  description = "ECS task execution role name"
}

output "private_subnets" {
  value       = module.networking.private_subnets
  description = "Private subnets for tasks"
}

output "public_subnets" {
  value       = module.networking.public_subnets
  description = "Public subnets for tasks"
}