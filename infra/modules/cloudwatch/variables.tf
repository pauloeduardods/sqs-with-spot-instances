variable "project_name" {
  description = "Project name"
  type        = string
}

variable "lambda_trigger" {
  description = "Lambda function to trigger"
  type        = object({
    name = string
    arn  = string
  })
}