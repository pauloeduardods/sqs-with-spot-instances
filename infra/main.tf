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
  # lambda_trigger = module.lambda.lambda_create_spot_instance
  sqs_queue_name = module.sqs_queue.sqs_queue.name
  scale = {
    scale_out_arn = module.auto_scaling_group.auto_scaling_policy.scale_out_arn
    scale_in_arn = module.auto_scaling_group.auto_scaling_policy.scale_in_arn
  }
}

module "auto_scaling_group" {
  source      = "./modules/asg"

  project_name = var.project_name
  # sqs_queue_name = module.sqs_queue.sqs_queue_name
  # scale = {
  #   scale_out_arn = module.lambda.lambda_scale_out_arn
  #   scale_in_arn  = module.lambda.lambda_scale_in_arn
  # }
  
}

# module "lambda" {
#   source      = "./modules/lambda/functions/create-spot-instance"

#   project_name = var.project_name
# }