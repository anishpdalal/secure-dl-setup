variable "keys_bucket" {
  description = "s3 bucket to place public ssh keys in that are synced to bastion instance"
  type        = string
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

variable "region" {
    type = string
}

