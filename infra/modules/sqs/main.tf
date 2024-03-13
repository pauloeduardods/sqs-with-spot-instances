resource "aws_sqs_queue" "sqs_queue_dlq" {
  name                       = "${var.project_name}aws_sqs_queue_policydlq.fifo"
  fifo_queue                 = true
  visibility_timeout_seconds = 30
  content_based_deduplication = false
}

resource "aws_sqs_queue" "sqs_queue" {
  name                       = "${var.project_name}.fifo"
  fifo_queue                 = true
  visibility_timeout_seconds = 90
  message_retention_seconds  = 864000
  receive_wait_time_seconds  = 20
  content_based_deduplication = false
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_queue_dlq.arn
    maxReceiveCount     = 2
  })
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