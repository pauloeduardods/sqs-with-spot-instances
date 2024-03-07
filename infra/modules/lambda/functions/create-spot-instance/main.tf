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

resource "aws_iam_role" "iam_for_lambda_create_spot_instance" {
  name               = "iam_for_lambda_create_spot_instance"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_create_spot_instance_exec_policy" {
  name   = "${var.project_name}_lambda_create_spot_instance_exec_policy"
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ec2:DescribeInstances",
          "ec2:RequestSpotInstances",
          "sqs:GetQueueAttributes"
        ],
        Resource = "*",
        Effect   = "Allow",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "lambda_create_spot_instance_exec_policy_attach" {
  role       = aws_iam_role.iam_for_lambda_create_spot_instance.name
  policy_arn = aws_iam_policy.lambda_create_spot_instance_exec_policy.arn
}

resource "aws_lambda_function" "create_spot_instance_lambda" {
  function_name = "${var.project_name}_create_spot_instance_lambda"
  handler       = "main"
  runtime       = "provided.al2"
  role          = aws_iam_role.iam_for_lambda_create_spot_instance.arn

  filename         = "./modules/lambda/functions/create-spot-instance/bin/create-spot-instance.zip"

  source_code_hash = filebase64sha256("./modules/lambda/functions/create-spot-instance/bin/create-spot-instance.zip")

  environment {
    variables = {
      EXAMPLE_VARIABLE = "value"
    }
  }
}