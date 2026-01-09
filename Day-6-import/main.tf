resource "aws_instance" "name" {
  ami = "ami-07ff62358b87c7116"
  instance_type = "t3.micro"
  tags = {
    Name = "nagendra_testing"
  }
}