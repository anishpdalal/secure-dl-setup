variable "vpc_name" {
  description = "Name of new VPC"
  type        = string
}

variable "cidr" {
  description = "Range of ip addresses for VPC"
  type        = string
}

variable "availability_zones" {
  description = "subregions to place VPC resources in"
  type        = list(string)
}

variable "private_subnets" {
  type            = list(string)
}

variable "public_subnets" {
  type            = list(string)
}