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

variable "config_asg" {
  description = "Lambda function configuration"
  type = object({
    min_instances      = number
    max_instances      = number
    message_threshold  = number 
  })
  default = {
    min_instances      = 0
    max_instances      = 3
    message_threshold  = 50
  }
}

variable "config_ec2" {
  description = "EC2 instance configuration"
  type = object({
    instance_type = string
    spot_price    = number
  })
  default = {
    spot_price    = 0.005
    instance_type = "t2.micro"
  }
}