resource "aws_cloudwatch_event_rule" "lambda_resize_asg_rule" {
  name                = "${var.project_name}_lambda_resize_asg"
  description         = "Rule to call lambda to resize ASG"
  schedule_expression = "rate(5 minutes)"
  tags = {
    "Name" = "SpotInstanceQueue_${var.project_name}"
  }
}

resource "aws_cloudwatch_event_target" "lambda_resize_asg_target" {
  rule      = aws_cloudwatch_event_rule.lambda_resize_asg_rule.name
  target_id = "CallLambdaResizeASG"
  arn       = var.lambda_resize_asg.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_resize_asg.name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_resize_asg_rule.arn 
}