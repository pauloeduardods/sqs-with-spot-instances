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