resource "aws_instance" "dev_instance" {
  ami           = "ami-07ff62358b87c7116" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t3.medium"
  
  tags = {
    Name = "Target_Resource_Instance"
  
}
}

resource "aws_s3_bucket" "name" {
  bucket = "nagendraindhuja143-target-resource" # Change to a unique name
  acl    = "private"

  tags = {
    Name = "Target_Resource_S3_Bucket"
  }
}
