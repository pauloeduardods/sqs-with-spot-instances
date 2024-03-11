variable "project_name" {
  description = "Project name"
  type        = string
}

variable "sqs_queue_name" {
  description = "SQS queue name"
  type        = string
}

variable "scale" {
  description = "Scale out and scale in ARN"
  type        = object({
    scale_out_arn = string
    scale_in_arn  = string
  })
  
}

# variable "lambda_trigger" {
#   description = "Lambda function to trigger"
#   type        = object({
#     name = string
#     arn  = string
#   })
# }