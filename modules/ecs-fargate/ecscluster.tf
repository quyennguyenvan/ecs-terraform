resource "aws_ecs_cluster" "ecs-cluster" {
  name = var.ecs_cluster_name
}

resource "aws_ecs_task_definition" "task-def" {
  family                   = "${var.ecs_cluster_name}-task-farmily"
  network_mode             = var.ecs_network_mode
  requires_compatibilities = [var.ecs_capacity_providers]
  cpu                      = var.cpu_request
  memory                   = var.memory_request
  execution_role_arn       = aws_iam_role.tasks-service-role.arn
  container_definitions    = <<EOF
  {[
    {
      "image" : "${var.image_url}",
      "cpu" : "${var.cpu_request}",
      "memory" : "${var.memory_request}",
      "name" : "${var.ecs_cluster_name}",
      "essential" : "${var.essential}",
      "networkMode" : "awsvpc",
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "${var.cw_log_group}",
          "awslogs-region" : "${var.current_region}",
          "awslogs-stream-prefix" : "${var.cw_log_stream}"
        }
      },
      "portMappings" : [
        {
          "containerPort" : "${var.container_port}",
          "hostPort" : "${var.container_port}"
        }
      ]
    }
  ]}
EOF
}


resource "aws_ecs_service" "service" {
  depends_on = [
    aws_alb_listener.alb-listener,
  ]
  name            = "${var.ecs_cluster_name}-Service"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.task-def.arn
  desired_count   = var.ecs_desired_count
  launch_type     = var.ecs_capacity_providers

  network_configuration {
    security_groups = [aws_security_group.task-sg.id]
    subnets         = var.private_subnet_ids
  }
  lifecycle {
    ignore_changes = [desired_count]
  }
  dynamic "load_balancer" {
    for_each = var.enable_application_loadbalancer ? [1] : []
    content {
      target_group_arn = aws_alb_target_group.trgp[0].id
      container_name   = var.ecs_cluster_name
      container_port   = var.container_port
    }
  }


}
resource "aws_appautoscaling_target" "ServiceAutoScalingTarget" {
  count              = var.enable_scaling ? 1 : 0
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
  resource_id        = "service/${aws_ecs_cluster.ecs-cluster.name}/${aws_ecs_service.service.name}" # service/(clusterName)/(serviceName)
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  lifecycle {
    ignore_changes = [
      min_capacity,
      max_capacity,
    ]
  }
}


resource "aws_cloudwatch_log_group" "ez-services-cw-lgrp" {
  name = var.cw_log_group
  tags = var.default_tags
}
