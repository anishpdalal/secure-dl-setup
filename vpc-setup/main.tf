provider "aws" {
  region = var.region
}

module "private_vpc" {
    source             = "../modules/private-vpc"

    vpc_name           = var.vpc_name
    cidr               = var.cidr
    availability_zones = var.availability_zones
    private_subnets    = var.private_subnets
    public_subnets     = var.public_subnets
}