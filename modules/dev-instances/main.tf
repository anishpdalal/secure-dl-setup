data "aws_vpc" "selected_vpc" {
  id = var.vpc_id
}

data "aws_subnet_ids" "private" {
  vpc_id = var.vpc_id

  tags = {
    terraform_name = "${data.aws_vpc.selected_vpc.tags.Name}-private-terraform"
  }
}

resource "aws_s3_bucket" "data_bucket" {
  bucket = var.data_bucket
  acl    = "private"
}

resource "aws_security_group" "sg" {
  name   = "ml_security_group"
  vpc_id =  var.vpc_id

  dynamic "ingress" {
    for_each = var.service_ports
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = [data.aws_vpc.selected_vpc.cidr_block]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

resource "aws_iam_instance_profile" "dev_instance_profile" {
  name = "dev_iam_instance_profile"
  role = aws_iam_role.dev_instance_ec2_role.name
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



resource "aws_instance" "instance" {
  for_each               = {for pair in var.key_pairs : pair.name => pair}
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = tolist(data.aws_subnet_ids.private.ids)[0]
  vpc_security_group_ids = [aws_security_group.sg.id]
  iam_instance_profile   = aws_iam_instance_profile.dev_instance_profile.name
  key_name               = "${each.key}-public-key"

  user_data = file("userdata.sh")

  tags = {
    Name = each.key
  }
}

