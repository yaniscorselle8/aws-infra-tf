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
  } #not for private
}

//Create Route Table : public
resource "aws_route_table" "private_route_table" {
  count  = var.is_public == "private" ? 1 : 0
  vpc_id = var.vpc_id
  tags = {
    Name = "route-table-yanis-${var.is_public}"
  }
  route {
    cidr_block = var.out_cidr_block
    gateway_id = var.gateway_id
  } #TO DO : FIX RESSOURCE TO REMOVE PUBLIC ROUTE AND STILL BE ABLE TO USE REMOTE PROVISIONNER
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

