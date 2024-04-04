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

variable "config" {
  description = "Config"
  type        = object({
    min_containers = number
    max_containers = number
    message_threshold = number
  })
}