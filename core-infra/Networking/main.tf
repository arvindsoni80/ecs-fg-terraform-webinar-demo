# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

/*==================================================
      AWS Networking for the whole solution
===================================================*/

# ------- VPC Creation -------
resource "aws_vpc" "aws_vpc" {
  cidr_block           = var.cidr[0]
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "vpc_${var.name}"
  }
}

# ------- Get Region Available Zones -------
data "aws_availability_zones" "az_availables" {
  state = "available"
}

# ------- Subnets Creation -------
# ------- The subnet prefix is expand by 'newbits' amount from the vpc 
# ------- 'newbits' is the sufficient binary digits to represent both private and public subnets
# ------- for vpc with /16 and 3 public and 3 private subnets, newbits will be 3 
# ------- Public subnets will occupy 1,2,3 value in the newbits 
# ------- Private subnets will occupy 4,5,6 value in the newbits

# ------- Public Subnets -------
resource "aws_subnet" "public_subnets" {
  count                   = var.public_subnet_count
  availability_zone       = data.aws_availability_zones.az_availables.names[count.index]
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.aws_vpc.cidr_block, ceil(log(var.public_subnet_count+var.private_subnet_count,2)), count.index + 1)
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_${count.index}_${var.name}"
  }
}

# ------- Private Subnets -------
resource "aws_subnet" "private_subnets" {
  count             = var.private_subnet_count
  availability_zone = data.aws_availability_zones.az_availables.names[count.index]
  vpc_id            = aws_vpc.aws_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.aws_vpc.cidr_block, ceil(log(var.public_subnet_count+var.private_subnet_count,2)), count.index + var.public_subnet_count + 1)
  tags = {
    Name = "private_subnet_${count.index}_${var.name}"
  }
}


# ------- Internet Gateway -------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.aws_vpc.id
  tags = {
    Name = "igw_${var.name}"
  }
}

# ------- Create Default Route Public Table -------
resource "aws_default_route_table" "rt_public" {
  default_route_table_id = aws_vpc.aws_vpc.default_route_table_id

  # ------- Internet Route -------
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt_${var.name}"
  }
}

# ------- Create EIP -------
resource "aws_eip" "eip" {
  vpc = true
  tags = {
    Name = "eip-${var.name}"
  }
}

# ------- Attach EIP to Nat Gateway -------
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
  tags = {
    Name = "nat_${var.name}"
  }
}

# ------- Create Private Route Private Table -------
resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.aws_vpc.id

  # ------- Internet Route -------
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "private_rt_${var.name}"
  }
}

# ------- Private Subnets Association -------
resource "aws_route_table_association" "rt_assoc_priv_subnets" {
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.rt_private.id
}

# ------- Public Subnets Association -------
resource "aws_route_table_association" "rt_assoc_pub_subnets" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_vpc.aws_vpc.main_route_table_id
}