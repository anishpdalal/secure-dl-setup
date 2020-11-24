provider "aws" {
  region = var.region
}

module "dev-instances" {
    source          = "../modules/dev-instances"

    vpc_id          = var.vpc_id
    ami             = var.ami
    data_bucket     = var.data_bucket
    service_ports   = var.service_ports
    instance_type   = var.instance_type 
    key_pairs       = var.key_pairs
}