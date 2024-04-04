variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "subnet" {
  description = "The subnet configuration"
  type        = object({
    ids = list(string)
  })
}

variable "security_group" {
  description = "The security group configuration"
  type        = object({
    ids = list(string)
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
    url = string
  })
}

variable "region" {
  description = "The region"
  type        = string
}