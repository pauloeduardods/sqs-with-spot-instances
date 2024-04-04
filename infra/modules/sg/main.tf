resource "aws_security_group" "allow_ssh" {
  name   = "${var.project_name}-allow-ssh_sg"

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

  tags = {
    Name = "SpotFargateQueue_${var.project_name}"
    CreatedBy = "Terraform"
  }
}

resource "aws_security_group" "allow_internet_traffic" {
  name   = "${var.project_name}_allow_internet_sg"

  vpc_id = var.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SpotFargateQueue_${var.project_name}"
    CreatedBy = "Terraform"
  }
}