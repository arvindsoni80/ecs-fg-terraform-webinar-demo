# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

variable "name" {
  description = "The name for the ECS Task Execution Role"
  type        = string
  default     = "ECS-task-excecution-Role"
}

variable "create_ecs_task_execution_role" {
  description = "Set this variable to true if you want to create a role for ECS Task Execution"
  type        = bool
  default     = false
}
