output "iam_for_lambda_create_spot_instance" {
  description = "IAM role for lambda to create spot instance"
  value       = aws_iam_role.iam_for_lambda_create_spot_instance
}