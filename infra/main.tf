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
    min_instances      = var.config_asg.min_instances
    max_instances      = var.config_asg.max_instances
    message_threshold  = var.config_asg.message_threshold
  }
}

module "ec2" {
  source      = "./modules/ec2"

  project_name = var.project_name
  ec2_config = {
    instance_type = var.config_ec2.instance_type
    spot_price    = var.config_ec2.spot_price
    ami_id = var.config_ec2.ami_id
  }
}

module "auto_scaling_group" {
  source      = "./modules/asg"

  project_name = var.project_name
  process_queue_launch_configuration = module.ec2.process_queue_launch_configuration
  asg_config = {
    min_size = var.config_asg.min_instances
    max_size = var.config_asg.max_instances
  }
}