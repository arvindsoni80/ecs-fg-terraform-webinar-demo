# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

/*===========================
          Root file
============================*/

# ------- Providers -------
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

# ------- Account ID -------
data "aws_caller_identity" "id_current_account" {}

# ------- Networking -------
module "networking" {
  source = "./Networking"
  cidr   = ["10.120.0.0/16"]
  name   = var.environment_name
}

# ------- Creating ECS Cluster -------
module "ecs_cluster" {
  source = "./Cluster"
  name   = var.environment_name
}

# ------- Creating ECS Task Execution Role -------
module "ecs_task_execution_role" {
  source                         = "./IAM"
  create_ecs_task_execution_role = true
  name                           = "${var.environment_name}_ecs_task_execution_role"
}
