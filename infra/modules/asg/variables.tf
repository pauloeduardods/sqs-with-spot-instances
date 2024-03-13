variable "project_name" {
  description = "Project name"
  type        = string
}

variable "process_queue_launch_configuration" {
  description = "The launch configuration for the process queue"
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