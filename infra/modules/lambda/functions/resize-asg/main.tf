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

resource "aws_iam_role" "iam_for_lambda_resize_asg" {
  name               = "${var.project_name}_iam_for_lambda_resize_asg"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_resize_asg_exec_policy" {
  name   = "${var.project_name}_lambda_resize_asg_exec_policy"
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
        Action   = [
          "autoscaling:DescribeAutoScalingGroups",
        ],
        Resource = "*",
        Effect   = "Allow",
      },
      {
        Action   = [
          "autoscaling:SetDesiredCapacity",
        ],
        Resource = var.asg.arn,
        Effect   = "Allow",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "lambda_resize_asg_exec_policy_attach" {
  role       = aws_iam_role.iam_for_lambda_resize_asg.name
  policy_arn = aws_iam_policy.lambda_resize_asg_exec_policy.arn
}

resource "aws_lambda_function" "lambda_function" {
  function_name = "${var.project_name}_resize_asg_lambda"
  description = "Resize ASG Lambda function for ${var.project_name}"
  handler       = "main"
  runtime       = "provided.al2"
  role          = aws_iam_role.iam_for_lambda_resize_asg.arn

  filename         = "./modules/lambda/functions/resize-asg/bin/resize-asg.zip"

  source_code_hash = filebase64sha256("./modules/lambda/functions/resize-asg/bin/resize-asg.zip")

  environment {
    variables = {
      REGION = var.region,
      SQS_QUEUE_URL = var.sqs.url,
      ASG_NAME = var.asg.name,
      MIN_INSTANCES = var.config.min_instances,
      MAX_INSTANCES = var.config.max_instances,
      MESSAGE_THRESHOLD = var.config.message_threshold,
    }
  }

  tags = {
    Name = "SpotInstanceQueue_${var.project_name}"
  }
}