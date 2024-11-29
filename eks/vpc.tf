# VPC
locals {
  cidr = "10.0.0.0/16"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>5.0"
  name    = "${local.cluster_name}-vpc"
  cidr    = local.cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  // will provision a NAT gateway for each private subnet, default is false
  enable_nat_gateway = true
  single_nat_gateway = true
  // will assign a dns hostname if the instance has been assigned a public ip, default is false
  enable_dns_hostnames = true

  public_subnet_tags = {
    "Name"                   = "public-${local.cluster_name}"
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "Name"                            = "private-${local.cluster_name}"
    "kubernetes.io/role/internal-elb" = 1
  }
}