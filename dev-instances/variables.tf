variable "service_ports" {
  type              = list(number)
  default           = [22, 6006, 8888]
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

variable "data_bucket" {
  description = "s3 bucket that will store data for dev instances"
  type        = string
}

variable "ami" {
  type        = string
  default     = "ami-01aad86525617098d"
}

variable "vpc_id" {
  description = "vpc id to place public keys bucket in"
  type        = string
}

variable "region" {
  description = "Target region for deploying VPC"
  type        = string
  default     = "us-east-1"
}

