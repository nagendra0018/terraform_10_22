module "name" {
  source = "../Day-7-Modules"
  ami_id = "ami-07ff62358b87c7116"
  instance_type = "t3.medium"
  instance_name = "nagendra_testing"
  vpc_cidr = "10.0.0.0/16"
  vpc_name = "nagendra_vpc"
  subnet_cidr = "10.0.1.0/24"
  subnet_name = "nagendra_subnet"
  availability_zone = "us-east-1a"
  region = "us-east-1"
}