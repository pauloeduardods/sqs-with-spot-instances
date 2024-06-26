resource "aws_sqs_queue" "sqs_queue_dlq" {
  name                       = "${var.project_name}-dlq.fifo"
  fifo_queue                 = true
  visibility_timeout_seconds = 30
  content_based_deduplication = false
}

resource "aws_sqs_queue" "sqs_queue" {
  name                       = "${var.project_name}.fifo"
  fifo_queue                 = true
  visibility_timeout_seconds = 60 * 20
  message_retention_seconds  = 60 * 60 * 24 * 10
  receive_wait_time_seconds  = 20
  content_based_deduplication = true
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_queue_dlq.arn
    maxReceiveCount     = 2
  })
  tags = {
    Name = "SpotFargateQueue_${var.project_name}"
    CreatedBy = "Terraform"
  }
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.sqs_queue.url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = [
        "SQS:SendMessage",
        "SQS:ReceiveMessage",
        "SQS:DeleteMessage"
      ]
      Resource  = aws_sqs_queue.sqs_queue.arn
    }]
  })
}