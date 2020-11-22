provider "aws" {
  region = var.region
}

module "bastion" {
    source          = "../modules/bastion"

    vpc_id          = var.vpc_id
    key_pairs       = var.key_pairs
    keys_bucket     = var.keys_bucket
    region          = var.region
}