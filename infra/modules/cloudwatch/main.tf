resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  alarm_name          = "${var.project_name}-scale-out-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "30" # increase
  statistic           = "Average"
  threshold           = "5"
  alarm_description   = "Scale out when there are more than 5 messages in the queue"
  dimensions = {
    QueueName = var.sqs_queue_name
  }
  alarm_actions = [var.scale.scale_out_arn]
}

resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_name          = "${var.project_name}-scale-in-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "30" #increase 
  statistic           = "Average"
  threshold           = "3"
  alarm_description   = "Scale in when there are less than 3 messages in the queue"
  dimensions = {
    QueueName = var.sqs_queue_name
  }
  alarm_actions = [var.scale.scale_in_arn]
}