resource "aws_cloudwatch_metric_alarm" "sqs_queue_alarm" {
  alarm_name          = "${var.project_name}_messages_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Average"
  threshold           = var.max_messages_threshold

  dimensions = {
    QueueName = "${var.project_name}.fifo"
  }

  alarm_description = "Alarm when there are ${var.max_messages_threshold} or more messages in the queue"
  alarm_actions     = [ var.lambda_trigger_arn ]
}