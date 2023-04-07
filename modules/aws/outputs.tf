output "subnet_id" {
  description = "ID of project VPC"
  value       = aws_subnet.app_pub_subnet.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.app_sec_group.id
}