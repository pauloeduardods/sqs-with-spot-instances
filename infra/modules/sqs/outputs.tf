output "sqs_queue_arn" {
  description = "SQS Queue ARN"
  value       = aws_sqs_queue.sqs_queue.arn
}

output "sqs_queue_dlq_arn" {
  description = "SQS Queue Dead Letter Queue ARN"
  value       = aws_sqs_queue.sqs_queue_dlq.arn
}