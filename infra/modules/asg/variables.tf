variable "project_name" {
  description = "Project name"
  type        = string
}

variable "process_queue_launch_template" {
  description = "The launch template for the EC2 instances"
  type        = object({
    name = string
    id   = string
  })
}

variable "asg_config" {
  description = "Auto Scaling Group configuration"
  type        = object({
    min_size         = number
    max_size         = number
  })
}

variable "subnet" {
  description = "The subnet"
  type        = object({
    ids = list(string)
  })
}

variable "ecs_cluster" {
  description = "The ECS cluster"
  type        = object({
    name = string
  })
}