# module "ec2_instance" {
#   source        = "./modules/ec2-instance"
#   ami_id        = var.ec2_ami
#   instance_type = var.ec2_type
#   environment   = var.environment
# }

module "sqs_queue" {
  source      = "./modules/sqs"

  project_name = var.project_name
}

module "cloudwatch" {
  source      = "./modules/cloudwatch"

  project_name = var.project_name
  lambda_trigger = module.lambda.lambda_create_spot_instance
}

module "lambda" {
  source      = "./modules/lambda/functions/create-spot-instance"

  project_name = var.project_name
}