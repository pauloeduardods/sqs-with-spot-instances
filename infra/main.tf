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

module "ecr" {
  source      = "./modules/ecr"

  project_name = var.project_name
}

module "vpc" {
  source      = "./modules/vpc"
}

module "security_group" {
  source      = "./modules/sg"

  project_name = var.project_name
  allow_ssh = true
  vpc = module.vpc.vpc
}

module "ecs" {
  source      = "./modules/ecs"

  project_name = var.project_name
  security_group = {
    ids = [module.security_group.allow_ssh.id, module.security_group.allow_internet_traffic.id]
  }
  subnet = module.vpc.subnets
  asg_config = {
    min_size = var.config_asg.min_instances
  }
  ecr_repo = module.ecr.ecr_repo
  sqs_queue = module.sqs_queue.sqs_queue
}

module "ec2" {
  source      = "./modules/ec2"

  project_name = var.project_name
  ec2_config = {
    instance_type = var.config_ec2.instance_type
    spot_price    = var.config_ec2.spot_price
    security_group = {
      ids = [module.security_group.allow_ssh.id, module.security_group.allow_internet_traffic.id]
    }
  }
  region = var.region
  sqs_queue = module.sqs_queue.sqs_queue
  max_workers = var.max_workers
  ecs_cluster = module.ecs.ecs_cluster
}

module "auto_scaling_group" {
  source      = "./modules/asg"

  project_name = var.project_name
  process_queue_launch_template = module.ec2.process_queue_launch_template
  subnet = module.vpc.subnets
  asg_config = {
    min_size = var.config_asg.min_instances
    max_size = var.config_asg.max_instances
  }

  ecs_cluster = module.ecs.ecs_cluster
}