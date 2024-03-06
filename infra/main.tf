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
  max_messages_threshold = 2 # change this to var
  lambda_trigger_arn = module.lambda.lambda_create_spot_instance_arn
}

module "iam" {
  source      = "./modules/iam"

  project_name = var.project_name 
}

module "lambda" {
  source      = "./modules/lambda"
  lambda_create_spot_instance_role_arn = module.iam.iam_for_lambda_create_spot_instance.arn
  project_name = var.project_name
  cloudwatch_sqs_queue_alarm_arn = module.cloudwatch.cloudwatch_sqs_queue_alarm_arn
}