output "lambda_function" {
  description = "Lambda function to resize ECS"
  value       = {
    name = aws_lambda_function.lambda_function.function_name
    arn  = aws_lambda_function.lambda_function.arn
  }
}