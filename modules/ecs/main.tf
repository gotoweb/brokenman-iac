resource "aws_ecs_cluster" "cluster" {
  name = var.name
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.name}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name = "${var.name}-iam-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRolePolicy" {
  role = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecsSecretsManagerReadWrite" {
  role = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

data "aws_ecs_task_definition" "app" {
  task_definition = aws_ecs_task_definition.app.family
}

resource "aws_ecs_task_definition" "app" {
  family = "${var.name}-td"
  container_definitions = var.container_definitions
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = "1024"
  memory = "3072"
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_service" "app" {
  name = "${var.name}-service"
  cluster = aws_ecs_cluster.cluster.id
  task_definition = "${aws_ecs_task_definition.app.family}:${max(aws_ecs_task_definition.app.revision, data.aws_ecs_task_definition.app.revision)}"
  launch_type = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count = 2
  force_new_deployment = true

  network_configuration {
    subnets = var.service_subnets
    assign_public_ip = false
    security_groups = var.service_security_groups
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name = "${var.name}-container"
    container_port = var.container_port
  }

  depends_on = [
    aws_lb_listener.listener
  ]
}

resource "aws_alb" "alb" {
  name = "${var.name}-alb"
  internal = false
  load_balancer_type = "application"
  subnets = var.alb_subnets
  security_groups = var.service_security_groups

  tags = {
    Name = "${var.name}-alb"
  }
}

resource "aws_lb_target_group" "target_group" {
  name = "${var.name}-tg-blue"
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = var.vpc_id

  health_check {
    healthy_threshold = "5"
    interval = "30"
    protocol = "HTTP"
    matcher = "200"
    timeout = "5"
    path = "/"
    unhealthy_threshold = "2"
  }

  tags = {
    Name = "${var.name}-tg-blue"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.alb.id
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_group.id
  }
}