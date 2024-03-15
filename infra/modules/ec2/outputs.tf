output "process_queue_launch_template" {
  value = {
    name         = aws_launch_template.process_queue_launch_template.name
    id          = aws_launch_template.process_queue_launch_template.id
  }
}