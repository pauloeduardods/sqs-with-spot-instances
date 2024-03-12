variable "project_name" {
  description = "Project name"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "sqs" {
  description = "SQS"
  type        = object({
    arn = string
    url = string
  })
}

variable "asg" {
  description = "ASG"
  type        = object({
    arn = string
    name = string
  })
}

variable "config" {
  description = "Config"
  type        = object({
    min_instances = number
    max_instances = number
    message_threshold = number
  })
}