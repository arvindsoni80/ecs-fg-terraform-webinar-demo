# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

/*===========================================
      AWS IAM for ECS Task Execution Role
============================================*/

# ------- IAM Roles -------
resource "aws_iam_role" "ecs_task_excecution_role" {
  count              = var.create_ecs_task_execution_role == true ? 1 : 0
  name               = var.name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = {
    Name = var.name
  }

  lifecycle {
    create_before_destroy = true
  }
}
# ------- IAM Policies -------


# ------- IAM Policies Attachments -------

# ------- AmazonECSTaskExecutionRolePolicy is a managed policy which provides ECR access 
# ------- and CloudWatch logging access using default awslogs driver
# ------- To do: expand this policy to include secrets manager and parameter store access
resource "aws_iam_role_policy_attachment" "attachment" {
  count      = length(aws_iam_role.ecs_task_excecution_role) > 0 ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_excecution_role[0].name

  lifecycle {
    create_before_destroy = true
  }
}