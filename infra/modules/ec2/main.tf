resource "aws_launch_configuration" "process_queue_launch_configuration" {
  name          = "${var.project_name}_spot_instance_config"
  image_id      = "ami-0f403e3180720dd7e"
  instance_type = var.ec2_config.instance_type
  spot_price    = var.ec2_config.spot_price

  # lifecycle {
  #   create_before_destroy = true
  # }
}