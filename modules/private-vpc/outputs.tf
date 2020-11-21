output "vpc_id" {
    value       = module.vpc.vpc_id
    description = "VPC ID of created private vpc"
}

output "vpc_name" {
    value       = module.vpc.name
    description = "VPC name of created private vpc"
}

