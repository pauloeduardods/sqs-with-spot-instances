variable "project_name" {
  description = "Project name"
  type        = string
}

variable "lambda_create_spot_instance_role_arn" {
  description = "The ARN of the IAM role to use for the lambda function"
  type        = string
}

variable "cloudwatch_sqs_queue_alarm_arn" {
  description = "The ARN of the CloudWatch alarm for the SQS queue"
  type        = string
}