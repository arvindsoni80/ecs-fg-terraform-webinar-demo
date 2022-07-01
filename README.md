# About
This repository contains code used for demo as part of the webinar 'Application Modernization with ECS Fargate - No Ph.D. Required'

The application code is in a separate public repository - https://github.com/arvindsoni80/ecsdemo-frontend 

In this repository there are following main folders
- [core-infra/](https://github.com/arvindsoni80/ecs-fg-terraform-webinar-demo/tree/main/core-infra): this folder contains terraform modules to create ECS cluster, VPC and subnets, and task execution role. This is all the infrastructure that is needed to get started with ECS Fargate! You may not even need to create the VPC and subnets and can use the existing ones.


- ecsdemo-frontend-deployment/: this folder contains:
-- Load-balanced ECS service creation resources including ECS service, ALB, target group, and associate security groups
-- ECS task definition for the service
-- ECR repository for the image used in the task
-- CodeBuild to build ECR images
-- CodePipeline to coordinate the image build whenever code is changed in the application repository main branch, and deploy the new image via rolling deployment using ECS 
-- S3 bucket to store build related assets



