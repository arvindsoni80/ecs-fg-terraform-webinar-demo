# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

variable "aws_profile" {
  description = "The profile name that you have configured in the file .aws/credentials"
  type        = string
}

variable "buildspec_path" {
  description = "The location of the buildspec file"
  type        = string
  default     = "./Templates/buildspec.yml"
}

variable "folder_path" {
  description = "The location of the server files"
  type        = string
  default     = "./."
}
variable "repository_owner" {
  description = "The name of the owner of the Github repository"
  type        = string
  default     = "arvindsoni80"
}

variable "repository_name" {
  description = "The name of the Github repository"
  type        = string
  default     = "ecsdemo-frontend"
}

variable "repository_branch" {
  description = "The name of branch the Github repository, which is going to trigger a new CodePipeline excecution"
  type        = string
  default     = "master"
}

variable "github_token" {
  description = "Personal access token from Github"
  type        = string
  sensitive   = true
  default     = "xxxxxxxxxxx"
}