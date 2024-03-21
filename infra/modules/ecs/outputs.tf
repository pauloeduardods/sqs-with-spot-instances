output "ecs_cluster" {
  value = {
    name = aws_ecs_cluster.ecs_cluster.name
  }
}