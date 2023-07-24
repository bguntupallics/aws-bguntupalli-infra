data "aws_region" "current" {}
data "aws_partition"        "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

data "http" "myip" {
  url = "https://ipinfo.io/ip"
}

# Getting AMI Information ----------------------------------------------------------------------------------------------

data "aws_ami" "amzn-linux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
}

locals {
  region = var.region
  account_id = data.aws_caller_identity.current.account_id
  allowed_cidr_blocks = "${chomp(data.http.myip.response_body)}/32"
}

# Getting VPC Details --------------------------------------------------------------------------------------------------

data "aws_vpc" "selected" {
  filter {
    name = "tag-value"
    values = [var.vpc_name]
  }
  filter {
    name = "tag-key"
    values = ["Name"]
  }
}

# Getting Subnets ------------------------------------------------------------------------------------------------------

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  tags = {
    Tier = "Private"
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id = each.value
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  tags = {
    Tier = "Public"
  }
}
data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public.ids)
  id = each.value
}

locals {
  az_public_subnet_ids = {
    for subnet in data.aws_subnet.public :
    subnet.availability_zone => subnet.id
  }
  az_private_subnet_ids = {
    for subnet in data.aws_subnet.private :
    subnet.availability_zone => subnet.id
  }
}