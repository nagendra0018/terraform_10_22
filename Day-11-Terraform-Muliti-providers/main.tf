resource "aws_instance" "name" {
  ami           = var.ami_id # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
  
}
resource "aws_s3_bucket" "name" {
  bucket = "nagendraindhuja143" # Change to a unique name
  acl    = "private"
  provider = aws.values["us-east-1"]
  tags = {
    Name = "MyS3Bucket"
  }
}