output "vpc" {
  value = {
    id = data.aws_vpc.default.id
  }
}

output "subnets" {
  value = {
    ids = data.aws_subnets.default.ids
  }
}