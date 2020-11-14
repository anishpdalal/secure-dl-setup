provider "aws" {
  region = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.cidr

  azs             = var.zones
  private_subnets = var.pri_subnets
  public_subnets  = var.pub_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true
}

resource "aws_s3_bucket" "ssh_bucket" {
  bucket = var.public_key_bucket
  acl    = "private"
}

resource "aws_s3_bucket" "data_bucket" {
  bucket = var.data_bucket
  acl    = "private"
}

resource "aws_s3_bucket_object" "ssh_public_keys" {
  for_each   = {for pair in var.key_pairs : pair.name => pair}

  bucket = aws_s3_bucket.ssh_bucket.bucket
  key    = "${each.key}.pub"

  source = each.value.public_key_path

  depends_on = [aws_s3_bucket.ssh_bucket]
}

resource "aws_iam_role" "bastion_ec2_role" {
  name = "bastion_ec2_role"
  path = "/"

  assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Action": "sts:AssumeRole",
		"Principal": {
			"Service": "ec2.amazonaws.com"
		},
		"Effect": "Allow",
		"Sid": ""
	}]
}
  EOF
}

resource "aws_iam_role" "dev_instance_ec2_role" {
  name = "dev_instance_ec2_role"
  path = "/"

  assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Action": "sts:AssumeRole",
		"Principal": {
			"Service": "ec2.amazonaws.com"
		},
		"Effect": "Allow",
		"Sid": ""
	}]
}
  EOF
}

resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "bastion_iam_instance_profile"
  role = aws_iam_role.bastion_ec2_role.name
}

resource "aws_iam_instance_profile" "dev_instance_profile" {
  name = "dev_iam_instance_profile"
  role = aws_iam_role.dev_instance_ec2_role.name
}

resource "aws_iam_role_policy" "s3_readonly_policy" {
  name = "s3_read_only_policy"
  role = aws_iam_role.bastion_ec2_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:List*"
        ],
        "Resource": ["${aws_s3_bucket.ssh_bucket.arn}"]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:Get*"
        ],
        "Resource": ["${aws_s3_bucket.ssh_bucket.arn}/*"]
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "s3_read_write_policy" {
  name = "s3_read_write_policy"
  role = aws_iam_role.dev_instance_ec2_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:List*"
        ],
        "Resource": ["${aws_s3_bucket.data_bucket.arn}"]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:Get*",
          "s3:Put*",
          "s3:Delete*"
        ],
        "Resource": ["${aws_s3_bucket.data_bucket.arn}/*"]
      }
    ]
  }
  EOF
}

module "bastion" {
  source                      = "github.com/terraform-community-modules/tf_aws_bastion_s3_keys"
  ami                         = "ami-0817d428a6fb68645"
  region                      = var.region
  iam_instance_profile        = aws_iam_instance_profile.bastion_instance_profile.name
  s3_bucket_name              = aws_s3_bucket.ssh_bucket.bucket
  vpc_id                      = module.vpc.vpc_id
  subnet_ids                  = module.vpc.public_subnets
  keys_update_frequency       = "*/5 * * * *"
  associate_public_ip_address = true
}

resource "aws_key_pair" "kp" {
  for_each   = {for pair in var.key_pairs : pair.name => pair}
  key_name   = "${each.key}-public-key"
  public_key = file(each.value.public_key_path)
}

resource "aws_security_group" "sg" {
  name   = "ml_security_group"
  vpc_id =  module.vpc.vpc_id

  dynamic "ingress" {
    for_each = var.service_ports
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "instance" {
  for_each               = {for pair in var.key_pairs : pair.name => pair}
  ami                    = "ami-01aad86525617098d"
  instance_type          = var.instance_type
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.sg.id]
  iam_instance_profile   = aws_iam_instance_profile.dev_instance_profile.name
  key_name               = "${each.key}-public-key"

  user_data = file("userdata.sh")

  tags = {
    Name = each.key
  }
}