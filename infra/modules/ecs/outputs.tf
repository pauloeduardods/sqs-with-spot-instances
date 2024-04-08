output "ecs_cluster" {
  value = {
    name = aws_ecs_cluster.ecs_cluster.name
  }
}

output "ecs_service" {
  value = {
    name = aws_ecs_service.app_service.name
  }
}