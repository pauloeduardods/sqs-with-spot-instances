output "allow_ssh" {
  value = {
    id = aws_security_group.allow_ssh.id
    name = aws_security_group.allow_ssh.name
  }
}