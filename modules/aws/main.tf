locals {
  cidr_block = var.is_public == "public" ? var.out_cidr_block : "${chomp(data.http.myip.response_body)}/32"
}
//Create subnet 
resource "aws_subnet" "app_pub_subnet" {
  cidr_block = var.subnet_cidr_block
  vpc_id     = var.vpc_id

  tags = {
    Name = "app-subnet-yanis-${var.is_public}"
  }
}

//Create Route Table : public
resource "aws_route_table" "pub_route_table" {
  count  = var.is_public == "public" ? 1 : 0
  vpc_id = var.vpc_id
  tags = {
    Name = "route-table-yanis-${var.is_public}"
  }
  route {
    cidr_block = var.out_cidr_block
    gateway_id = var.gateway_id
  }
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}
//Create Route Table : private
resource "aws_route_table" "private_route_table" {
  count  = var.is_public == "private" ? 1 : 0
  vpc_id = var.vpc_id
  tags = {
    Name = "route-table-yanis-${var.is_public}"
  }
  route {
    cidr_block = "${chomp(data.http.myip.response_body)}/32"
    gateway_id = var.gateway_id
  } #this route permits me to access the private subnet (only my public ip so it's still private)
  route {
    cidr_block = var.out_cidr_block
    gateway_id = var.gateway_id
  } #comment this route after first execution of the EC2
  lifecycle {
    ignore_changes = [
      route,
    ]
  }
}

//Associate Public Route Table to Subnet
resource "aws_route_table_association" "public_rt_subnet_association" {
  count          = var.is_public == "public" ? 1 : 0
  route_table_id = aws_route_table.pub_route_table[count.index].id
  subnet_id      = aws_subnet.app_pub_subnet.id
}

//Associate Private Route Table to Subnet
resource "aws_route_table_association" "private_rt_subnet_association" {
  count          = var.is_public == "private" ? 1 : 0
  route_table_id = aws_route_table.private_route_table[count.index].id
  subnet_id      = aws_subnet.app_pub_subnet.id
}

//Create Security Group
resource "aws_security_group" "app_sec_group" {
  vpc_id = var.vpc_id

  egress {
    cidr_blocks = [var.out_cidr_block]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = var.ingress_protocol
    cidr_blocks = [local.cidr_block]
  }

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = var.ingress_protocol
    cidr_blocks = [var.out_cidr_block]
  }
}