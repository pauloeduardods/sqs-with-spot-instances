resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/ecs/${var.project_name}"
  tags = {
    Name      = "ECSLogGroup_${var.project_name}"
    CreatedBy = "Terraform"
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}_ecs_cluster"
  tags = {
    Name        = "SpotInstanceQueue_${var.project_name}"
    CreatedBy   = "Terraform"
  }
}

resource "aws_iam_role" "ecs_tasks_execution_role" {
  name = "${var.project_name}_ecs_tasks_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "app_ecs_policy" { 
  name        = "${var.project_name}_app_ecs_policy"
  description = "Allow EC2 instances to interact with SQS and CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ],
        Resource = "*",
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

resource "aws_iam_role_policy_attachment" "ecs_tasks_exec_policy_attachment" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = aws_iam_policy.app_ecs_policy.arn
}


resource "aws_ecs_task_definition" "ecs_app_task" {
  family                   = "${var.project_name}_app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "128"
  memory                   = "300"
  execution_role_arn       = aws_iam_role.ecs_tasks_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}_container",
      image     = "${var.ecr_repo.repository_url}:latest",
      cpu       = 128,
      memory    = 300,
      essential = true,
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name,
          awslogs-region        = var.region,
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "app_service" {
  name            = "${var.project_name}_service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_app_task.arn
  desired_count   = 2 # TODO: Change this in lambda 
  launch_type     = "EC2"

  network_configuration {
    subnets         = var.subnet.ids
    security_groups = var.security_group.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_tasks_exec_policy_attachment
  ]
}