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

variable "service" {
  description = "The name of the service being created."
  type        = string
}

variable "environment" {
  type        = string
  description = "Application environment"
}

variable "deployment_id" {
  description = "An identifier for this instantiation. e.g. abc1, tenant1, tenant2 etc."
  type        = string
}

variable "vpc_name" {
  description = "Name of VPC"
  type        = string
}

variable "default_tags" {
  type        = map(string)
  default     = {
    environment = "dev"
    version     = "0.0.1"
  }
  description = "Default Tags"
}

variable tags {
  type        = map(any)
  description = "An object of tag key value pairs"
  default     = {}
}

variable "instance_az" {
  description = "instance availability Zone"
  type        = string
}

variable "instance_public" {
  description = "Should be true if you want to provision in public networks"
  type        = bool
  default     = true
}

variable "aws_profile" {
  description = "AWS profile"
}