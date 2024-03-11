resource "aws_launch_configuration" "process_queue_launch_configuration" {
  name          = "${var.project_name}-spot-instance-config"
  image_id      = "ami-0f403e3180720dd7e"
  instance_type = "t2.micro"
  spot_price    = "0.004"

  # lifecycle {
  #   create_before_destroy = true
  # }
}