data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_cloudwatch_event_rule" "lambda_resize_ecs_rule" {
  name                = "${var.project_name}_lambda_resize_ecs"
  description         = "Rule to call lambda to resize ECS"
  schedule_expression = "rate(5 minutes)"
  tags = {
    Name = "SpotFargateQueue_${var.project_name}"
    CreatedBy = "Terraform"
  }
}

resource "aws_cloudwatch_event_target" "lambda_resize_ecs_target" {
  rule      = aws_cloudwatch_event_rule.lambda_resize_ecs_rule.name
  target_id = "CallLambdaResizeECS"
  arn       = aws_lambda_function.lambda_function.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_resize_ecs_rule.arn 
}

resource "aws_iam_role" "iam_for_lambda_resize_ecs" {
  name               = "${var.project_name}_iam_for_lambda_resize_ecs"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_resize_ecs_exec_policy" {
  name   = "${var.project_name}_lambda_resize_ecs_exec_policy"
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*",
        Effect   = "Allow",
      },
      {
        Action   = [
          "sqs:GetQueueAttributes",
        ],
        Resource = var.sqs.arn,
        Effect   = "Allow",
      },
      {
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
        ],
        Resource = "*",
        Effect   = "Allow",
      },
      # {
      #   Action   = [
      #     "ecs:UpdateService",
      #   ],
      #   Resource = var.ecs.arn,
      #   Effect   = "Allow",
      # }
    ],
  })
}

resource "aws_iam_role_policy_attachment" "lambda_resize_ecs_exec_policy_attach" {
  role       = aws_iam_role.iam_for_lambda_resize_ecs.name
  policy_arn = aws_iam_policy.lambda_resize_ecs_exec_policy.arn
}

resource "aws_lambda_function" "lambda_function" {
  function_name = "${var.project_name}_resize_ecs_lambda"
  description = "Resize ECS Lambda function for ${var.project_name}"
  handler       = "main"
  runtime       = "provided.al2"
  role          = aws_iam_role.iam_for_lambda_resize_ecs.arn

  filename         = "./modules/lambda/functions/resize-ecs/bin/resize-ecs.zip"

  source_code_hash = filebase64sha256("./modules/lambda/functions/resize-ecs/bin/resize-ecs.zip")

  environment {
    # TODO: fazer as alteracoes necessarias para o ambiente (colocar as envs necessarias)
    variables = {
      REGION = var.region,
      SQS_QUEUE_URL = var.sqs.url,
      ECS_SERVICE_NAME = var.ecs.name,
      ECS_CLUSTER_NAME = var.ecs.cluster,
      MIN_CONTAINERS = var.config.min_containers,
      MAX_CONTAINERS = var.config.max_containers,
      MESSAGE_THRESHOLD = var.config.message_threshold,
    }
  }

  tags = {
    Name = "SpotFargateQueue_${var.project_name}"
    CreatedBy = "Terraform"
  }
}