variable "instance_type" {
  type = string
}

variable "service_ports" {
  type = list(number)
}

variable "key_pairs" {
  type = list(object({
        name = string,
        public_key_path = string
  }))
}

variable "vpc_id" {
  description = "vpc id to place public keys bucket in"
  type        = string
}

variable "ami" {
  type = string
}

variable "data_bucket" {
  description = "s3 bucket that will store data for dev instances"
  type        = string
}