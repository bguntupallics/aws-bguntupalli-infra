variable "region" {
  default = "us-east-1"
  type = string
  description = "East Coast Region"
}

variable "vpc-name" {
  default = "vpc1"
  type = string
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default = "t2.micro"
}

variable "resource_type" {
  default = "t2.micro"
  type = string
}