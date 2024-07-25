resource "aws_ecs_cluster" "app_cluster" {
  name = var.app_name
}

resource "aws_launch_configuration" "ecs_instance" {
  name                        = "${var.app_name}-ecs-instance"
  image_id                    = data.aws_ami.ecs_ami.id
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.name
  associate_public_ip_address = true
  security_groups             = [aws_security_group.ecs_sg.id]
  user_data                   = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.app_cluster.name} >> /etc/ecs/ecs.config
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  launch_configuration = aws_launch_configuration.ecs_instance.id
  min_size             = 1
  max_size             = 1
  desired_capacity     = 1
  vpc_zone_identifier  = aws_subnet.public[*].id 

  tag {
    key                 = "Name"
    value               = "${var.app_name}-ecs-instance"
    propagate_at_launch = true
  }
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
 name = "/ecs/${var.app_name}"
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = var.app_name
      image     = "${aws_ecr_repository.app.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.app_name}"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}


resource "aws_ecs_service" "app_service" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "EC2"
  network_configuration {
    subnets          = aws_subnet.public[*].id 
    security_groups  = [aws_security_group.app_sg.id]
    assign_public_ip = false
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.app_name}-sg"
  description = "Security group for ECS service"
  vpc_id      = aws_vpc.main.id  # Use the VPC ID from the VPC resource

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_security_group" "app_sg" {
  name        = "${var.app_name}-app-sg"
  description = "Security group for ${var.app_name} ECS service"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ecs_ami" {
  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  most_recent = true
  owners      = ["amazon"]
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}_ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.app_name}_ecs_instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  ]
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.app_name}_ecs_instance_profile"
  role = aws_iam_role.ecs_instance_role.name
}
