variable "region" {
  description = "Target region for deploying VPC"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Name of new VPC"
  type        = string
}

variable "cidr" {
  description = "Range of ip addresses for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "subregions to place VPC resources in"
  type        = list(string)
  default     = ["us-east-1a"]
}

variable "private_subnets" {
  type            = list(string)
  default         = ["10.0.1.0/24"]
}

variable "public_subnets" {
  type            = list(string)
  default         = ["10.0.101.0/24"]
}
