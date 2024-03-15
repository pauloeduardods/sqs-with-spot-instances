resource "aws_security_group" "allow_ssh" {
  name   = "${var.project_name}_sg"

  vpc_id = var.vpc.id

  dynamic "ingress" {
    for_each = var.allow_ssh ? [1] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere in dev
    }
  }
}