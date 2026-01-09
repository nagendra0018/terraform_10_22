#Create a VPC with a CIDR block of 10.0.0.0/16

resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "nagendra_vpc"
  }
  
}

#2.Create subnet within the VPC with a CIDR block of
resource "aws_subnet" "name" {
  vpc_id                  = aws_vpc.name.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public_subnet-1"
  }
}

resource "aws_subnet" "name1" {
  vpc_id                  = aws_vpc.name.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public_subnet-2"
  }
}

resource "aws_subnet" "name2" {
  vpc_id = aws_vpc.name.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Private_subnet-1"
  }
}

resource "aws_subnet" "name3" {
  vpc_id = aws_vpc.name.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private_subnet-2"
  }
  
}

#3.Create an Internet Gateway and attach it to the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.name.id
  tags = {
    Name = "nagendra_igw"
  }
}

#4.Create a route table for the public subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.name.id
  tags = {
    Name = "Public_Route_Table"
  }
}
#5.Create a route in the public route table to direct internet-bound traffic to the Internet Gateway
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
#6.Associate the public subnets with the public route table
resource "aws_route_table_association" "public_rt_assoc1" {
  subnet_id      = aws_subnet.name.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_rt_assoc2" {
  subnet_id      = aws_subnet.name1.id
  route_table_id = aws_route_table.public_rt.id
}
#7.Create a NAT Gateway in one of the public subnets
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "NAT_EIP"
  }
}
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.name.id
  tags = {
    Name = "NAT_Gateway"
  }
}
#8.Create a route table for the private subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.name.id
  tags = {
    Name = "Private_Route_Table"
  }
}
#9.Create a route in the private route table to direct internet-bound traffic to the NAT Gateway
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}
#10.Associate the private subnets with the private route table
resource "aws_route_table_association" "private_rt_assoc1" {  
  subnet_id      = aws_subnet.name2.id
  route_table_id = aws_route_table.private_rt.id
}
resource "aws_route_table_association" "private_rt_assoc2" {  
  subnet_id      = aws_subnet.name3.id
  route_table_id = aws_route_table.private_rt.id
}
#12.Create Security Groups
resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "Allow inbound HTTP and SSH traffic"
  vpc_id      = aws_vpc.name.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "Allow SSH from public subnets and all outbound traffic"
  vpc_id      = aws_vpc.name.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24", "10.0.1.0/24"]
    description = "Allow SSH from public subnets"
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Allow ICMP from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private_sg"
  }
}

#12.Create ec2 

resource "aws_instance" "name" {
  ami           = "ami-07ff62358b87c7116" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.name.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "Bastion_Host_1"
  }
  
}

resource "aws_instance" "public_name" {
  ami           = "ami-07ff62358b87c7116" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.name1.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "Bastion_Host_2"
  }
  
}

resource "aws_instance" "private_name" {
  ami           = "ami-07ff62358b87c7116" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.name2.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  tags = {
    Name = "Private_Host_1"
  }
  
}

resource "aws_instance" "private_name_1" {
  ami           = "ami-07ff62358b87c7116" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.name3.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  tags = {
    Name = "Private_Host_2"
  }
  
}

#13.Output the VPC ID, Subnet IDs, Internet Gateway ID, and NAT Gateway ID
output "vpc_id" { 
  value = aws_vpc.name.id
}
output "public_subnet_ids" {
  value = [aws_subnet.name.id, aws_subnet.name1.id]
}
output "private_subnet_ids" {
  value = [aws_subnet.name2.id, aws_subnet.name3.id]
}
output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}
output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gw.id
}

