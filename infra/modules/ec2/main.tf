data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.*-x86_64-ebs"]
  }
}

resource "aws_iam_role" "ecsInstanceRole" {
  name               = "ecsInstanceRole-${var.project_name}"
  assume_role_policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Sid       = "",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecsInstanceRolePolicy" {
  name   = "ecsInstanceRolePolicy-${var.project_name}"
  role   = aws_iam_role.ecsInstanceRole.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecs:CreateCluster",
          "ecs:DeregisterContainerInstance",
          "ecs:DiscoverPollEndpoint",
          "ecs:Poll",
          "ecs:RegisterContainerInstance",
          "ecs:StartTelemetrySession",
          "ecs:Submit*",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "ecsServiceRole" {
  name               = "ecsServiceRole-${var.project_name}"
  assume_role_policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "ecs.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy" "ecsServiceRolePolicy" {
  name   = "ecsServiceRolePolicy-${var.project_name}"
  role   = aws_iam_role.ecsServiceRole.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:Describe*",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "elasticloadbalancing:RegisterTargets"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ecsInstanceProfile" {
  name = "ecsInstanceProfile-${var.project_name}"
  role = aws_iam_role.ecsInstanceRole.name
}

resource "aws_launch_template" "process_queue_launch_template" {
  name          = "${var.project_name}_spot_instance_lt"
  image_id      = data.aws_ami.ecs_ami.id
  instance_type = var.ec2_config.instance_type
  # vpc_security_group_ids = var.ec2_config.security_group.ids ### TODO: se isso der bom remover o sg var

  iam_instance_profile {
    name = aws_iam_instance_profile.ecsInstanceProfile.id
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

  monitoring {
    enabled = true
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.ecs_cluster.name} >> /etc/ecs/ecs.config
    EOF
  )

  tags = {
    Name = "SpotInstanceQueue_${var.project_name}"
    CreatedBy = "Terraform"
  }
}
