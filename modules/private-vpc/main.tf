module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.cidr

  azs                = var.availability_zones
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  public_subnet_tags = {"terraform_name": "${var.vpc_name}-public-terraform"}

  enable_nat_gateway = true
  enable_vpn_gateway = true
}