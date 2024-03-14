resource "aws_cloudwatch_log_group" "ec2_log_group" {
  name = "/ecs/${var.project_name}-spot-instance"
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid = ""
      },
    ]
  })
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_policy"
  description = "Allow EC2 instances to interact with SQS and CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*",
        Effect   = "Allow"
      },
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
        Effect = "Allow",
      },
      {
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = var.sqs_queue.arn,
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ec2_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_launch_configuration" "process_queue_launch_configuration" {
  name          = "${var.project_name}_spot_instance_config"
  image_id =    var.ec2_config.ami_id
  instance_type = var.ec2_config.instance_type
  spot_price    = var.ec2_config.spot_price
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = base64encode(
    <<-EOF
     $(aws ecr get-login --no-include-email --region ${var.region})
    docker pull ${var.ecr_repo.repository_url}:latest
    docker run -d \
      --log-driver=awslogs \
      --log-opt awslogs-region=${var.region} \
      --log-opt awslogs-group=${aws_cloudwatch_log_group.ec2_log_group.name} \
      ${var.ecr_repo.repository_url}:latest
    EOF
  )
  # lifecycle {
  #   create_before_destroy = true
  # }
}