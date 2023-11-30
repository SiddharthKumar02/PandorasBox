# Terraform Configuration for VPN Server and Windows 10 Instance
provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "vpn_server" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  subnet_id     = "subnet-12345678"
  key_name      = "my_keypair"
  
  user_data = <<-EOF
              #!/bin/bash
              echo "VPN IP: 172.23.165.2"
              echo "Username: HOUDINI\dcopperfield"
              echo "Password: tartans@123"
              # Additional VPN configuration here
              EOF
}

resource "aws_instance" "windows_machine" {
  ami           = "ami-87654321" # Windows 10 AMI ID
  instance_type = "t2.micro"
  subnet_id     = "subnet-12345678"
  key_name      = "my_keypair"
  
  provisioner "file" {
    source      = "scripts/domain_join.ps1"
    destination = "C:/domain_join.ps1"
  }
  
  connection {
    type        = "winrm"
    user        = "Administrator"
    password    = "AdminPass123!" # Replace with a secure password
    port        = 5986
    https       = true
    timeout     = "10m"
    insecure    = true
  }
  
  provisioner "remote-exec" {
    inline = [
      "powershell.exe -ExecutionPolicy Unrestricted -File C:/domain_join.ps1"
    ]
  }
}
