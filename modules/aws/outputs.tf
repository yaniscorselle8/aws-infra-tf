output "public_ip" {
  description = "Public IP"
  value       = aws_instance.app.public_ip
}