output "public_ip" {
  description = "Public IP"
  value       = module.aws_ec2instance["public"]
}