variable "is_public" {}
variable "gateway_id" {}
variable "vpc_id" {}

variable "subnet_cidr_block" {}

variable "out_cidr_block" {
  default = "0.0.0.0/0"
}