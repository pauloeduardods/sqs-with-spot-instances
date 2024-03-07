resource "aws_cloudwatch_event_rule" "lambda_timer" {
  name                = "${var.project_name}_spot_instance_lambda_timer"
  description         = "Trigger Lambda every 10 minutes"
  schedule_expression = "rate(2 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.lambda_timer.name
  arn       = var.lambda_trigger.arn
  # input     = "{}"
}

resource "aws_lambda_permission" "allow_event_bridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_trigger.name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_timer.arn
}