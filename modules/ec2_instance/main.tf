locals {
  github_project_folder = var.is_public == "public" ? "angular" : "backend-Python"
  docker_cmd            = var.is_public == "public" ? "docker run -d -p 80:80 appweb" : "docker run -d -p 80:8080 appweb"
  cidr_block = var.is_public == "public" ? var.out_cidr_block : "${chomp(data.http.myip.response_body)}/32"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}


resource "aws_key_pair" "deployer" {
  key_name   = "aws_key-${var.is_public}"
  public_key = file("./aws_key.pub")
}

resource "aws_instance" "app" {
  ami                    = var.ubuntu_ami
  instance_type          = var.instance_type_ec2
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.app_sec_group.id]
  tags = {
    Name = "yanis-ubuntu-${var.is_public}"
  }
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./aws_key")
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

//Create Security Group
resource "aws_security_group" "app_sec_group" {
  vpc_id = var.vpc_id

  egress {
    cidr_blocks      = [var.out_cidr_block]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
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
    cidr_blocks = [local.cidr_block]
  }
}