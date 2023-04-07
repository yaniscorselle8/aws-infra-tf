locals {
   github_project_folder = var.is_public == "public" ? "angular" : "backend-Python"
  docker_cmd            = var.is_public == "public" ? "docker run -d -p 80:80 appweb" : "docker run -d -p 80:8080 appweb"
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
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"] #permits to grant ssh access only to the machine who launches terraform
  }

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = var.ingress_protocol
    cidr_blocks = [var.out_cidr_block]
  }
}

//Create AWS EC2 Instance
resource "aws_instance" "app" {
  ami                    = var.ubuntu_ami
  instance_type          = var.instance_type_ec2
  subnet_id              = aws_subnet.app_pub_subnet.id
  vpc_security_group_ids = [aws_security_group.app_sec_group.id]
  tags = {
    Name = "yanis-ubuntu-${var.is_public}"
  }
  key_name                    = var.aws_key_pair_name
  associate_public_ip_address = true
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./aws_key.pem")
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository -y deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable",
      "sudo apt-get update -y",
      "sudo apt-get -y install docker-ce docker-ce-cli containerd.io",
      "sudo usermod -aG docker ubuntu",
      "git clone https://github.com/raoufcherfa/Imad-aws",
      "sudo docker build -t appweb ./Imad-aws/${local.github_project_folder}",
      "sudo ${local.docker_cmd}"
    ]
  }
}