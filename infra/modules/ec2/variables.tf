variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "ec2_config" {
  description = "EC2 instance configuration"
  type        = object({
    instance_type = string
    spot_price    = number
  })
}

# variable "ami_id" {
#   description = "The AMI ID to use for the EC2 instance"
#   type        = string
# }