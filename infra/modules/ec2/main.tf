resource "aws_cloudwatch_log_group" "ec2_log_group" {
  name = "/ecs/${var.project_name}_spot_instance"
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}_ec2_role"

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
  name        = "${var.project_name}_ec2_policy"
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
  name = "${var.project_name}_ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_launch_template" "process_queue_launch_template" {
  name          = "${var.project_name}_spot_instance_lt"
  image_id      = var.ec2_config.ami_id
  instance_type = var.ec2_config.instance_type
  vpc_security_group_ids = var.ec2_config.security_group.ids

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = var.ec2_config.spot_price
    }
  }


  metadata_options {
    http_tokens = "required"
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo service docker start
    $(aws ecr get-login --no-include-email --region ${var.region})
    docker pull ${var.ecr_repo.repository_url}:latest
    docker run -d \
      --log-driver=awslogs \
      --log-opt awslogs-region=${var.region} \
      --log-opt awslogs-group=${aws_cloudwatch_log_group.ec2_log_group.name} \
      ${var.ecr_repo.repository_url}:latest
    EOF
  )

  tags = {
    Name = "SpotInstanceQueue_${var.project_name}"
    CreatedBy = "Terraform"
  }
}
