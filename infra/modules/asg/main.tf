resource "aws_autoscaling_group" "process_queue_asg" {
  name = var.ecs_cluster.name
  min_size             = var.asg_config.min_size
  max_size             = var.asg_config.max_size
  vpc_zone_identifier = var.subnet.ids
  launch_template {
    id = var.process_queue_launch_template.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "SpotInstanceQueue_${var.project_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "ecs_cluster"
    value               = var.ecs_cluster.name
    propagate_at_launch = true
  }
}