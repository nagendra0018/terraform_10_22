# Key Pair - Using existing SSH public key from local system
resource "aws_key_pair" "example" {
  key_name   = "my-terraform-key"
  public_key = file("~/.ssh/id_rsa.pub")  # Change to your key path
  # For Windows: file("C:/Users/YourUsername/.ssh/id_rsa.pub")
  # For ed25519: file("~/.ssh/id_ed25519.pub")

  tags = {
    Name        = "Terraform-Key"
    Environment = "Development"
  }
}

# VPC for the instance
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "key-management-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}

# EC2 Instance
resource "aws_instance" "server" {
  ami                    = "ami-0261755bbcb8c4a84" # Ubuntu AMI
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.example.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apache2
              systemctl start apache2
              systemctl enable apache2
              echo "<h1>EC2 Instance with Existing SSH Key</h1>" > /var/www/html/index.html
              echo "<p>Key Pair: ${aws_key_pair.example.key_name}</p>" >> /var/www/html/index.html
              EOF

  tags = {
    Name        = "Ubuntu-Server"
    Environment = "Development"
  }
}

# Outputs
output "key_pair_name" {
  value       = aws_key_pair.example.key_name
  description = "Name of the key pair"
}

output "instance_public_ip" {
  value       = aws_instance.server.public_ip
  description = "Public IP of the EC2 instance"
}

output "instance_id" {
  value       = aws_instance.server.id
  description = "ID of the EC2 instance"
}

output "ssh_command" {
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.server.public_ip}"
  description = "SSH command to connect to the instance"
}

output "web_url" {
  value       = "http://${aws_instance.server.public_ip}"
  description = "URL to access the web server"
}
