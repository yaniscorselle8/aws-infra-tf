output "subnet_id" {
  description = "ID of project VPC"
  value       = aws_subnet.app_pub_subnet.id
}