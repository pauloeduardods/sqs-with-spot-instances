variable "environment" {
  description = "(Dev, Prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region. Ex: us-east-1, us-west-2, etc."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "dev-process-queue"
}

variable "ec2_ami" {
  description = "AWS EC2 AMI ID. Ex: ami-0f403e3180720dd7e, etc."
  type        = string
  default     = "ami-0f403e3180720dd7e"
}

variable "ec2_type" {
  description = "AWS EC2 instance type. Ex: t2.micro, t2.small, etc."
  type        = string
  default     = "t2.micro"
}