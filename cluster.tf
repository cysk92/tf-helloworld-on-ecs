resource "aws_ecs_task_definition" "helloworld-task-definition" {
  family                   = "helloworld"
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  container_definitions = <<DEFINITION
[
  {
    "image": "${var.image_address}",
    "cpu": 256,
    "memory": 512,
    "name": "helloworld-app",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_cluster" "main" {
  name = "kantox-helloworld-cluster"
}

resource "aws_ecs_service" "helloworld-service" {
  name                                = "helloworld-service"
  cluster                             = aws_ecs_cluster.main.id
  task_definition                     = aws_ecs_task_definition.helloworld-task-definition.arn
  desired_count                       = 2
  launch_type                         = "FARGATE"
  deployment_minimum_healthy_percent  = "50"
  deployment_maximum_percent          = "150"
  force_new_deployment                = true

  network_configuration {
    security_groups = [aws_security_group.helloworld-task-sg.id]
    subnets         = aws_subnet.private-subnet.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.helloworld-tg.id
    container_name   = "helloworld-app"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.helloworld-listener]
}
