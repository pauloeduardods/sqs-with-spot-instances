output "lambda_resize_asg" {
  description = "Lambda function to resize ASG"
  value       = {
    name = aws_lambda_function.lambda_resize_asg.function_name
    arn  = aws_lambda_function.lambda_resize_asg.arn
  }
}