resource "aws_instance" "name" {
  ami           = var.ami_id # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
  
}

resource "aws_vpc" "name" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }

  
}

resource "aws_subnet" "name" {
  vpc_id            = aws_vpc.name.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = var.subnet_name
  
  }
  
}