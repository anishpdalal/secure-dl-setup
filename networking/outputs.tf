output "private_vpc_id" {
    value       = module.private_vpc.vpc_id
    description = "VPC ID of created private vpc"
}

output "private_vpc_name" {
    value       = module.private_vpc.vpc_name
    description = "VPC Name of created private vpc"
}