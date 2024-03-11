data "aws_vpc" "selected" {
  default = true
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

resource "aws_autoscaling_group" "process_queue_asg" {
  name = "${var.project_name}-spot-instance-asg"
  launch_configuration = var.process_queue_launch_configuration.id
  min_size             = 0
  max_size             = 10
  desired_capacity     = 0

  vpc_zone_identifier = data.aws_subnets.selected.ids

  tag {
    key                 = "Name"
    value               = "SpotInstanceQueue"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.project_name}-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.process_queue_asg.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.project_name}-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.process_queue_asg.name
}