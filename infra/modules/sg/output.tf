output "allow_ssh" {
  value = {
    id = aws_security_group.allow_ssh.id
    name = aws_security_group.allow_ssh.name
  }
}

output "allow_internet_traffic" {
  value = {
    id = aws_security_group.allow_internet_traffic.id
    name = aws_security_group.allow_internet_traffic.name
  }
  
}