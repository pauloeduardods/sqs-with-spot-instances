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
  lambda_resize_asg = module.lambda_resize_asg.lambda_function
}

module "lambda_resize_asg" {
  source      = "./modules/lambda/functions/resize-asg"

  project_name = var.project_name
  region       = var.region
  sqs          = module.sqs_queue.sqs_queue
  asg          = module.auto_scaling_group.auto_scaling_group
  config = {
    min_instances = 0
    max_instances = 10
    message_threshold = 10
  }
}

module "ec2" {
  source      = "./modules/ec2"

  project_name = var.project_name
}

module "auto_scaling_group" {
  source      = "./modules/asg"

  project_name = var.project_name
  process_queue_launch_configuration = module.ec2.process_queue_launch_configuration
}