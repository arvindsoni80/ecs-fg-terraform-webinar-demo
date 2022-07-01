# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

variable "name" {
  description = "Provided name used for name concatenation of resources"
  type        = string
}

variable "cidr" {
  description = "CIDR block"
  type        = list(any)
}

variable "public_subnet_count" {
  description = "Number of public subnets to create"
  default     = 3
}

variable "private_subnet_count" {
  description = "Number of private subnets to create"
  default     = 3
}