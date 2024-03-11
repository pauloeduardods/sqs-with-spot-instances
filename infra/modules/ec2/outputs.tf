output "process_queue_launch_configuration" {
  value = {
    name         = aws_launch_configuration.process_queue_launch_configuration.name
    id          = aws_launch_configuration.process_queue_launch_configuration.id
  }
}