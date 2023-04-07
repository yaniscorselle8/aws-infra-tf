locals {
  github_project_folder = var.is_public == "public" ? "angular" : "backend-Python"
  docker_cmd            = var.is_public == "public" ? "docker run -d -p 80:80 appweb" : "docker run -d -p 80:8080 appweb"
}

//Create AWS EC2 Instance
resource "aws_instance" "app" {
  ami                    = var.ubuntu_ami
  instance_type          = var.instance_type_ec2
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
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