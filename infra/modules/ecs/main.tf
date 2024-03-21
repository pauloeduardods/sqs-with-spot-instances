resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}_ecs_cluster"
  tags = {
    Name        = "SpotInstanceQueue_${var.project_name}"
    CreatedBy   = "Terraform"
  }
}
