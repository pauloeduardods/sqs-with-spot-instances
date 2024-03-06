output "lambda_create_spot_instance_arn" {
  description = "Lambda function to create spot instance"
  value       = aws_lambda_function.create_spot_instance_lambda.arn
}