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