provider "aws" {
  region = var.aws_region
}

# Data source to get default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source to get available subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-security-group"
  description = "Security group for NGINX web server"
  vpc_id      = data.aws_vpc.default.id

  # HTTP access from anywhere
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access (optional - for debugging)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-security-group"
  }
}

# Get latest Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.10.20260120.4-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance
resource "aws_instance" "nginx_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  
  user_data = templatefile("${path.module}/user-data.sh", {
    private_ip = "PRIVATE_IP_PLACEHOLDER"
  })

  tags = {
    Name = "nginx-web-server"
  }
}


