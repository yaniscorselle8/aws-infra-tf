variable "is_public" {}
variable "gateway_id" {}
variable "vpc_id" {}
variable "subnet_cidr_block" {}
variable "aws_key_pair_name" {}
variable "ssh_port" {
  default = "22"
}

variable "http_port" {
  default = "80"
}

variable "out_cidr_block" {
  default = "0.0.0.0/0"
}
variable "ingress_protocol" {
  default = "tcp"
}

variable "instance_type_ec2" {
  default = "t2.micro"
}

variable "ubuntu_ami" {
  default = "ami-00aa9d3df94c6c354"
}