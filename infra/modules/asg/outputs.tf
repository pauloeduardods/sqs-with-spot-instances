output "auto_scaling_group" {
  description = "Auto Scaling Group"
  value       = {
    name = aws_autoscaling_group.process_queue_asg.name
    arn  = aws_autoscaling_group.process_queue_asg.arn
  }
}