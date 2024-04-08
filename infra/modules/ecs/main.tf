data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "allow_internet_traffic_sg" {
  name   = "${var.project_name}_allow_internet_sg"

  vpc_id = var.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SpotFargateQueue_${var.project_name}"
    CreatedBy = "Terraform"
  }
}

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
    Name        = "SpotFargateQueue_${var.project_name}"
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
  description = "Allow ECS tasks to interact with ECR and CloudWatch Logs"

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
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_exec_policy_attachment" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = aws_iam_policy.app_ecs_policy.arn
}

resource "aws_iam_role" "app_task_role" {
  name = "${var.project_name}_app_task_role"

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

resource "aws_iam_policy" "app_sqs_policy" {
  name        = "${var.project_name}_app_sqs_policy"
  description = "Policy for ECS Tasks to interact with SQS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = var.sqs_queue.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_task_role_policy_attachment" {
  role       = aws_iam_role.app_task_role.name
  policy_arn = aws_iam_policy.app_sqs_policy.arn
}

resource "aws_ecs_task_definition" "ecs_app_task" {
  family                   = "${var.project_name}_app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  task_role_arn            = aws_iam_role.app_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_tasks_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}_container",
      image     = "${var.ecr_repo.repository_url}:latest",
      cpu       = 256,
      memory    = 512,
      essential = true,
      environment = [
        {
          name  = "REGION",
          value = var.region
        },
        {
          name  = "SQS_QUEUE_URL",
          value = var.sqs_queue.url
        },
        {
          name  = "MAX_WORKERS",
          value = "2"
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
  desired_count   = var.config_containers.min_containers

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
    base              = 0
  }                   

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.allow_internet_traffic_sg.id]
    assign_public_ip = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_tasks_exec_policy_attachment
  ]
}