resource "aws_launch_configuration" "process_queue_launch_configuration" {
  name          = "${var.project_name}_spot_instance_config"
  image_id      = var.ev2_config.image_id
  instance_type = var.ec2_config.instance_type
  spot_price    = var.ec2_config.spot_price

  user_data = base64encode(
    <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup busybox httpd -f -p 80 &
    EOF
  )
  # lifecycle {
  #   create_before_destroy = true
  # }
}