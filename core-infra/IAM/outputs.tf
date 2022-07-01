# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "arn_role" {
  value = (var.create_ecs_task_execution_role == true
  ? (length(aws_iam_role.ecs_task_excecution_role) > 0 ? aws_iam_role.ecs_task_excecution_role[0].arn : "") : "")
}

output "name_role" {
  value = (var.create_ecs_task_execution_role == true
  ? (length(aws_iam_role.ecs_task_excecution_role) > 0 ? aws_iam_role.ecs_task_excecution_role[0].name : "") : "")
}