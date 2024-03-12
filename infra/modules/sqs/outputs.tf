output "sqs_queue" {
  description = "SQS Queue"
  value       = {
    name = aws_sqs_queue.sqs_queue.name
    arn  = aws_sqs_queue.sqs_queue.arn
    url = aws_sqs_queue.sqs_queue.url
  }
}

output "sqs_queue_dlq" {
  description = "SQS Queue Dead Letter Queue"
  value       = {
    name = aws_sqs_queue.sqs_queue_dlq.name
    arn  = aws_sqs_queue.sqs_queue_dlq.arn
    url = aws_sqs_queue.sqs_queue_dlq.url
  }
}