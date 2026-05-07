output "private_servers_subnet_id" {
  value       = aws_subnet.private_servers.id
  description = "Private servers subnet ID for downstream modules."
}

output "servers_sg_id" {
  value       = aws_security_group.servers.id
  description = "Servers security group ID for downstream modules."
}
