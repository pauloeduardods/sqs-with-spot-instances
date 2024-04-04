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

variable "config_containers" {
  description = "Lambda function configuration"
  type = object({
    min_containers      = number
    max_containers      = number
    message_threshold  = number 
  })
  default = {
    min_containers      = 0
    max_containers      = 3
    message_threshold  = 50
  }
}

variable "max_workers" {
  description = "The maximum number of workers to run"
  type        = number
  default     = 3
}