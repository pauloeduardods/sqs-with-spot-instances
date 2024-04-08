module "sqs_queue" {
  source      = "./modules/sqs"

  project_name = var.project_name
}

module "lambda_resize_ecs" {
  source      = "./modules/lambda/functions/resize-ecs"

  project_name = var.project_name
  region       = var.region
  sqs          = module.sqs_queue.sqs_queue
  config = {
    min_containers      = var.config_containers.min_containers
    max_containers      = var.config_containers.max_containers
    message_threshold  = var.config_containers.message_threshold
  }

  ecs = {
    cluster = module.ecs.ecs_cluster.name
    name    = module.ecs.ecs_service.name
  }
}

module "ecr" {
  source      = "./modules/ecr"

  project_name = var.project_name
}

module "ecs" {
  source      = "./modules/ecs"

  project_name = var.project_name
  ecr_repo = module.ecr.ecr_repo
  sqs_queue = module.sqs_queue.sqs_queue
  region = var.region
  config_containers = var.config_containers
}