output "auto_scaling_policy" {
  description = "Auto Scaling Policy"
  value       = {
    scale_out_arn = aws_autoscaling_policy.scale_out.arn
    scale_in_arn  = aws_autoscaling_policy.scale_in.arn
  }
}