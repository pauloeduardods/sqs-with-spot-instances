variable "project_name" {
  description = "Project name"
  type        = string
}

variable "max_messages_threshold" {
  description = "Threshold for the alarm"
  type        = number
  default     = 10
}

variable "lambda_trigger_arn" {
  description = "ARN of the lambda function"
  type        = string
}