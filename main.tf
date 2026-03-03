provider "aws" {
    region = "us-east-1"
}
resource "aws_key_pair" "deployer" {
  key_name   = "eks"
  public_key = file("~/.ssh/id_rsa.pub")  # Path to your public key
}

resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_ssh"
  description = "Allow SSH and HTTP inbound traffic"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # For testing only; restrict in prod
  }

  # HTTP (Port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "test" {
    ami = "ami-0f3caa1cf4417e51b"
    instance_type = "t3.micro"
    associate_public_ip_address = true
    key_name                    = aws_key_pair.deployer.key_name
    security_groups             = [aws_security_group.allow_http_ssh.name]
    user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y git python3
              cd /home/ec2-user
              git clone https://github.com/oendrella/oendrella.git
              cd your-python-app
              python3 -m pip install -r requirements.txt
              #nohup python3 app.py &
              # Run Python app on port 80
              nohup sudo python3 app.py --host=0.0.0.0 --port=80 &
              EOF

  tags = {
    Name = "PythonAppServer"
  }
}

output "public_ip" {
  value = aws_instance.test.public_ip
  description = "Public IP of the Python application server"
}

