module "ec2_instance" {
  source        = "./modules/ec2-instance"
  ami_id        = var.ec2_ami
  instance_type = var.ec2_type
  environment   = var.environment
}
