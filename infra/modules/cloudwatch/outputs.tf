output "cloudwatch_sqs_queue_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.sqs_queue_alarm.arn
}