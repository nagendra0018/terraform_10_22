resource "aws_instance" "name" {
  ami           = var.ami_id # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = var.instance_type
  user_data     = file("test.sh")

  tags = {
    Name = var.instance_name
  }
  
}

resource "aws_s3_bucket" "name" {
  bucket = "nagendraindhuja143" # Change to a unique name

  tags = {
    Name = "MyS3Bucket"
  }
}

# Separate resource for S3 bucket ACL (replaces deprecated acl parameter)
resource "aws_s3_bucket_acl" "name" {
  bucket = aws_s3_bucket.name.id
  acl    = "private"
}

# Optional: Block public access
resource "aws_s3_bucket_public_access_block" "name" {
  bucket = aws_s3_bucket.name.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
