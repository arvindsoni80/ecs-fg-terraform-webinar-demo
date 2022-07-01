# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

/*===========================
          Root file
============================*/

locals {
  service_name     = "frontend"
  service_port     = 3000
  service_protocol = "HTTP"
  desired_tasks    = 3

  lb_ingress_port       = 80
  health_check_path     = "/"
  health_check_matcher  = "200"
  health_check_port     = 3000
  health_check_protocol = "http"

  task_boot_time = 10

  autoscaling_attribute = "cpu"
  autoscaling_threshold = 50

  task_cpu    = 256
  task_memory = "512"
  # task_role_arn = ""

  container_name  = "frontend"
  container_port  = 3000
}

locals {
  env_name                     = "test"
  cluster_id                   = "arn:aws:ecs:us-east-1:xxxx:cluster/Cluster-test"
  cluster_name                 = "Cluster-test"
  cluster_region               = "us-east-1"
  ecs_task_execution_role_arn  = "arn:aws:iam::xxxx:role/test_ecs_task_execution_role"
  ecs_task_execution_role_name = "test_ecs_task_execution_role"
  private_subnets = [
    "subnet-xxxx",
    "subnet-xxxx",
    "subnet-xxxx",
  ]
  public_subnets = [
    "subnet-xxxx",
    "subnet-xxxx",
    "subnet-xxxx",
  ]
  vpc_id = "vpc-0c5b0c7efcd10c1ce"
}

# ------- Providers -------
provider "aws" {
  profile = var.aws_profile
  region  = local.cluster_region

  # provider level tags - yet inconsistent when executing 
  # default_tags {
  #   tags = {
  #     Created_by = "Terraform"
  #     Project    = "AWS_demo_fullstack_devops"
  #   }
  # }
}

# ------- Random numbers intended to be used as unique identifiers for resources -------
resource "random_id" "RANDOM_ID" {
  byte_length = "2"
}

# ------- Account ID -------
data "aws_caller_identity" "id_current_account" {}



# ------- Creating Target Group for the server ALB environment -------
module "target_group_task" {
  source              = "./Modules/ALB"
  create_target_group = true
  name                = "tg-${local.env_name}-${local.service_name}"
  port                = local.service_port
  protocol            = local.service_protocol
  vpc                 = local.vpc_id
  tg_type             = "ip"
  health_check_path   = local.health_check_path
  health_check_port   = local.health_check_port
}

# ------- Creating Security Group for the server ALB -------
module "security_group_alb_server" {
  source              = "./Modules/SecurityGroup"
  name                = "alb-${local.env_name}-${local.service_name}"
  description         = "Controls access to the server ALB"
  vpc_id              = local.vpc_id
  cidr_blocks_ingress = ["0.0.0.0/0"]
  ingress_port        = local.lb_ingress_port
}

# ------- Creating Server Application ALB -------
module "alb_server" {
  source         = "./Modules/ALB"
  create_alb     = true
  name           = "${local.env_name}-${local.service_name}"
  subnets        = local.public_subnets
  security_group = module.security_group_alb_server.sg_id
  target_group   = module.target_group_task.arn_tg
}

# ------- Creating server ECR Repository to store Docker Images -------
module "ecr_repo" {
  source = "./Modules/ECR"
  name   = "${local.env_name}-${local.service_name}-repo"
}

# ------- Creating ECS Task Definition for the server -------
module "ecs_task_definition" {
  source             = "./Modules/ECS/TaskDefinition"
  name               = "fe-task-def"
  container_name     = local.container_name
  execution_role_arn = local.ecs_task_execution_role_arn
  task_role_arn      = ""
  cpu                = local.task_cpu
  memory             = local.task_memory
  docker_repo        = module.ecr_repo.ecr_repository_url
  region             = local.cluster_region
  container_port     = local.container_port
}

# ------- Creating a server Security Group for ECS TASKS -------
module "security_group_ecs_task" {
  source          = "./Modules/SecurityGroup"
  name            = "ecs-task-${local.env_name}-${local.service_name}"
  description     = "Controls access to the ${local.service_name} ECS task"
  vpc_id          = local.vpc_id
  ingress_port    = local.service_port
  security_groups = [module.security_group_alb_server.sg_id]
}


# ------- Creating ECS Service -------
module "ecs_service_server" {
  depends_on          = [module.alb_server]
  source              = "./Modules/ECS/Service"
  name                = local.service_name
  desired_tasks       = local.desired_tasks
  arn_security_group  = module.security_group_ecs_task.sg_id
  ecs_cluster_id      = local.cluster_id
  arn_target_group    = module.target_group_task.arn_tg
  arn_task_definition = module.ecs_task_definition.arn_task_definition
  subnets_id          = local.private_subnets
  container_port      = local.container_port
  container_name      = local.container_name
}

# ------- CodePipeline -------

# ------- Creating Bucket to store CodePipeline artifacts -------
# ------- codepipeline-region-cluster-service
module "s3_codepipeline" {
  source      = "./Modules/S3"
  bucket_name = "codepipeline-${local.cluster_region}-${random_id.RANDOM_ID.hex}"
}

# ------- Creating IAM roles used during the pipeline excecution -------
module "devops_role" {
  source             = "./Modules/IAM"
  create_devops_role = true
  name               = "devops-role-${local.env_name}"
}

# ------- Creating an IAM Policy for role ------- 
module "policy_devops_role" {
  source               = "./Modules/IAM"
  name                 = "policy-devops-role-${local.env_name}"
  create_policy        = true
  attach_to            = module.devops_role.name_role
  create_devops_policy = true
  ecr_repositories     = [module.ecr_repo.ecr_repository_arn]
  code_build_projects  = [module.codebuild.project_arn]
}


# ------- Creating the CodeBuild project -------
module "codebuild" {
  source                 = "./Modules/CodeBuild"
  name                   = "codebuild-${local.env_name}-${local.service_name}"
  iam_role               = module.devops_role.arn_role
  region                 = local.cluster_region
  account_id             = data.aws_caller_identity.id_current_account.account_id
  ecr_repo_url           = module.ecr_repo.ecr_repository_url
  folder_path            = var.folder_path
  buildspec_path         = var.buildspec_path
  task_definition_family = module.ecs_task_definition.task_definition_family
  container_name         = local.container_name
  service_port           = local.service_port
  ecs_role               = local.ecs_task_execution_role_name
  server_alb_url         = module.alb_server.dns_alb
}

# ------- Creating CodePipeline -------
module "codepipeline" {
  source            = "./Modules/CodePipeline"
  name              = "pipeline-${local.env_name}-${local.service_name}"
  pipe_role         = module.devops_role.arn_role
  s3_bucket         = module.s3_codepipeline.s3_bucket_id
  github_token      = var.github_token
  repo_owner        = var.repository_owner
  repo_name         = var.repository_name
  branch            = var.repository_branch
  codebuild_project = module.codebuild.project_id
  ecs_cluster_name  = local.cluster_name
  ecs_service_name  = local.service_name
  depends_on        = [module.policy_devops_role]
}

