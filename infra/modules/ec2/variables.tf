variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "region" {
  description = "The AWS region"
  type        = string
}
variable "ec2_config" {
  description = "EC2 instance configuration"
  type        = object({
    instance_type = string
    spot_price    = number
    ami_id        = string
    security_group = object({
      ids = list(string)
    })
  })
}

variable "ecr_repo" {
  description = "The ECR repository"
  type        = object({
    repository_url = string
  })
}

variable "sqs_queue" {
  description = "The SQS queue"
  type        = object({
    arn = string
  })
}

# variable "ami_id" {
#   description = "The AMI ID to use for the EC2 instance"
#   type        = string
# }