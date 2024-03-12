variable "project_name" {
  description = "Project name"
  type        = string
}

variable "lambda_resize_asg" {
  description = "Lambda function to resize ASG"
  type        = {
    arn = string
    name = string
  }
}