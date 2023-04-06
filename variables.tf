variable "region" {
  default = "eu-west-1"
}

variable "access_key" {} #to set in terraform.tfvars

variable "secret_key" {} #to set in terraform.tfvars

variable "vpc_cidr_block" {
  default = "50.20.0.0/16"
}

variable "is_public" {
  type = map(string)
  default = {
    "public"  = "50.20.18.0/24",
    "private" = "50.20.5.0/24",
  }
}