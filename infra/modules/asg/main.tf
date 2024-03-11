data "aws_vpc" "selected" {
  default = true
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}
resource "aws_autoscaling_group" "asg_queue" {
  name = "${var.project_name}-spot-instance-asg"
  launch_configuration = aws_launch_configuration.asg_queue.id
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

resource "aws_launch_configuration" "asg_queue" {
  name          = "${var.project_name}-spot-instance-config"
  image_id      = "ami-0f403e3180720dd7e"
  instance_type = "t2.micro"
  spot_price    = "0.004"

  # lifecycle {
  #   create_before_destroy = true
  # }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg_queue.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg_queue.name
}