resource "aws_s3_bucket" "keys_bucket" {
  bucket = var.keys_bucket
  acl    = "private"
}

resource "aws_s3_bucket_object" "public_keys" {
  for_each   = {for pair in var.key_pairs : pair.name => pair}

  bucket = aws_s3_bucket.keys_bucket.bucket
  key    = "${each.key}.pub"

  source = each.value.public_key_path

  depends_on = [aws_s3_bucket.keys_bucket]
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

resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "bastion_iam_instance_profile"
  role = aws_iam_role.bastion_ec2_role.name
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
        "Resource": ["${aws_s3_bucket.keys_bucket.arn}"]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:Get*"
        ],
        "Resource": ["${aws_s3_bucket.keys_bucket.arn}/*"]
      }
    ]
  }
  EOF
}

data "aws_vpc" "selected_vpc" {
  id = var.vpc_id
}

data "aws_subnet_ids" "public" {
  vpc_id = var.vpc_id

  tags = {
    terraform_name = "${data.aws_vpc.selected_vpc.tags.Name}-public-terraform"
  }
}


module "bastion" {
  source                      = "github.com/terraform-community-modules/tf_aws_bastion_s3_keys"
  ami                         = "ami-0817d428a6fb68645"
  region                      = var.region
  iam_instance_profile        = aws_iam_instance_profile.bastion_instance_profile.name
  s3_bucket_name              = aws_s3_bucket.keys_bucket.bucket
  vpc_id                      = var.vpc_id
  subnet_ids                  = data.aws_subnet_ids.public.ids
  keys_update_frequency       = "*/5 * * * *"
  associate_public_ip_address = true
}

resource "aws_key_pair" "kp" {
  for_each   = {for pair in var.key_pairs : pair.name => pair}
  key_name   = "${each.key}-public-key"
  public_key = file(each.value.public_key_path)
}


