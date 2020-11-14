variable "region" {
  description = "Target region for deploying VPC"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Name of new VPC"
  type        = string
  default     = "ml-vpc"
}

variable "cidr" {
  description = "Range of ip addresses for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "zones" {
  description = "subregions to place VPC resources in"
  type        = list(string)
  default     = ["us-east-1a"]
}

variable "pri_subnets" {
  type            = list(string)
  default         = ["10.0.1.0/24"]
}

variable "pub_subnets" {
  type            = list(string)
  default         = ["10.0.101.0/24"]
}

variable "data_bucket" {
  description = "s3 bucket that will store data for ML stuff"
  type        = string
}

variable "public_key_bucket" {
  description = "s3 bucket to place public ssh keys in that are synced to bastion instance"
  type        = string
}

variable "instance_type" {
  type        = string
  default     = "p2.xlarge"
}

variable "key_pairs" {
  type = list(object({
        name = string,
        public_key_path = string
  }))
}

variable "service_ports" {
  type              = list(number)
  default           = [22, 6006, 8888]
}