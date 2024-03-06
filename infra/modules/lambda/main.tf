resource "aws_lambda_function" "create_spot_instance_lambda" {
  function_name = "${var.project_name}_create_spot_instance_lambda"
  handler       = "main"
  runtime       = "provided.al2"
  role          = var.lambda_create_spot_instance_role_arn

  filename         = "./modules/lambda/build/create-spot-instance.zip"

  source_code_hash = filebase64sha256("./modules/lambda/build/create-spot-instance.zip")

  environment {
    variables = {
      EXAMPLE_VARIABLE = "value"
    }
  }
}

# resource "aws_lambda_alias" "create_spot_instance_lambda_alias" {
#   name             = "create_spot_instance_lambda_alias"
#   description      = "create_spot_instance_lambda_alias"
#   function_name    = aws_lambda_function.create_spot_instance_lambda.function_name
#   function_version = "$LATEST"
# }

resource "aws_lambda_permission" "allow_cloudwatch_alarm_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromCloudWatchAlarm"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_spot_instance_lambda.function_name
  principal     = "lambda.alarms.cloudwatch.amazonaws.com"
  source_arn    = var.cloudwatch_sqs_queue_alarm_arn
  # qualifier =   aws_lambda_alias.create_spot_instance_lambda_alias.name
}