output "lambda_create_spot_instance" {
  description = "Lambda function to create spot instance"
  value       = {
    name = aws_lambda_function.create_spot_instance_lambda.function_name
    arn  = aws_lambda_function.create_spot_instance_lambda.arn
  }
}