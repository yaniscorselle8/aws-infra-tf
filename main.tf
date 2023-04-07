//create vpc
resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "app-vpc-yanis"
  }

  enable_dns_hostnames = true
}

//create internet gateway 
resource "aws_internet_gateway" "app_igw" {
  tags = {
    Name = "app-igw-yanis"
  }
}

//attach aws internet gateway with the VPC
resource "aws_internet_gateway_attachment" "aws_internet_gateway_attachment" {
  internet_gateway_id = aws_internet_gateway.app_igw.id
  vpc_id              = aws_vpc.app_vpc.id
}

//Create SSH key pair to connect to EC2 instances
resource "aws_key_pair" "deployer" {
  key_name   = "aws_key-yanis"
  public_key = file("./aws_key.pub")
}

//Call to AWS module
module "aws" {
  for_each          = var.is_public
  source            = "./modules/aws"
  is_public         = each.key
  gateway_id        = aws_internet_gateway.app_igw.id
  vpc_id            = aws_vpc.app_vpc.id
  subnet_cidr_block = each.value
  aws_key_pair_name = aws_key_pair.deployer.key_name
}
