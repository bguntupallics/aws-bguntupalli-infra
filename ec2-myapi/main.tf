# Security Group for MYAPI ----------------------------------------------------------------------------------------

resource "aws_security_group" "ec2-instance-sg" {
  name        = "${var.environment}-${var.deployment_id}-${var.service}-ec2-sg"
  description = "Allow SSH, ICMP Echo traffic, HTTP and HTTPS inbound connections"
  vpc_id = data.aws_vpc.selected.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.allowed_cidr_blocks] //["0.0.0.0/0"]
    #    cidr_blocks = cidr_blocks = local.allowed_cidr_blocks //["${local.ifconfig_co_json.ip}/32"]
  }

  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = [local.allowed_cidr_blocks] //[aws_security_group.alb-sg.id]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.allowed_cidr_blocks] //[aws_security_group.alb-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.default_tags,
    {
      "Name" = "${var.environment}-${var.deployment_id}-${var.service}"
    },
  )
}

# Cloud Config ---------------------------------------------------------------------------------------------------------

data "cloudinit_config" "init-config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "write-scripts.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/scripts/write-scripts.cfg", {
      REGION = var.region
    })
  }

  part {
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/scripts/install_docker.sh", {
    })
  }

  part {
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/scripts/start.sh", {
    })
  }
}

# EC2 Instance for MYApi -----------------------------------------------------------------------------------------------

resource "aws_instance" "this" {
  ami                     = data.aws_ami.amzn-linux2.image_id
  instance_type           = var.instance_type
  iam_instance_profile    = aws_iam_instance_profile.ec2-instance-profile.name
  subnet_id               = var.instance_public ? local.az_public_subnet_ids[var.instance_az] : local.az_private_subnet_ids[var.instance_az]
  vpc_security_group_ids  = [aws_security_group.ec2-instance-sg.id]
  associate_public_ip_address = var.instance_public ? true : false
  user_data               = data.cloudinit_config.init-config.rendered
  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
  tags = merge (
    {
      Name = "${var.environment}-${var.deployment_id}-${var.service}"
    },
    var.tags
  )
}

resource "aws_instance" "private-db" {
  ami                     = data.aws_ami.amzn-linux2.image_id
  instance_type           = var.instance_type
  iam_instance_profile    = aws_iam_instance_profile.ec2-instance-profile.name
  subnet_id               = var.instance_public ? local.az_public_subnet_ids[var.instance_az] : local.az_private_subnet_ids[var.instance_az]
  vpc_security_group_ids  = [aws_security_group.ec2-instance-sg.id]
  associate_public_ip_address = var.instance_public ? true : false
  user_data               = data.cloudinit_config.init-config.rendered
  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
  tags = merge (
    {
      Name = "${var.environment}-${var.deployment_id}-${var.service}"
    },
    var.tags
  )
}