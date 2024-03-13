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
  name = "${var.project_name}_spot_instance_asg"
  launch_configuration = var.process_queue_launch_configuration.id
  min_size             = var.asg_config.min_size
  max_size             = var.asg_config.max_size

  vpc_zone_identifier = data.aws_subnets.selected.ids

  tag {
    key                 = "Name"
    value               = "SpotInstanceQueue_${var.project_name}"
    propagate_at_launch = true
  }
}