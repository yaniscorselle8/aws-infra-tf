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

module "aws_subnet" {
  for_each          = var.is_public
  source            = "./modules/aws_subnet"
  is_public         = each.key
  gateway_id        = aws_internet_gateway.app_igw.id
  vpc_id            = aws_vpc.app_vpc.id
  subnet_cidr_block = each.value
}

module "aws_ec2instance" {
  for_each  = var.is_public
  source    = "./modules/ec2_instance"
  is_public = each.key
  vpc_id    = aws_vpc.app_vpc.id
  subnet_id = module.aws_subnet[each.key].subnet_id
}