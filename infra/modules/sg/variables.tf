variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "vpc" {
  description = "The VPC"
  type        = object({
    id = string
  })
}

variable "allow_ssh" {
  description = "Whether to allow SSH traffic"
  type        = bool
}