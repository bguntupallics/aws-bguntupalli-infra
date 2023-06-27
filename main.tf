data "aws_vpc" "first" {
  filter {
    name = "tag-key"
    values = ["Name"]
  }

  filter {
    name = "tag-value"
    values = [var.vpc-name]
  }
}

data "aws_subnets" "second" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.first.id]
  }

  tags = {
    Tier = "Private"
  }
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "test-instance" {
  ami = data.aws_ami.amazon-linux-2.id
  instance_type = var.resource_type
  subnet_id = data.aws_subnets.second.ids[0]

  tags = {
    Name = "individual"
  }
}