resource "aws_instance" "dev_instance" {
  ami           = "ami-07ff62358b87c7116" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t3.medium"
  
   lifecycle {
     create_before_destroy = true
   }

   lifecycle {
     ignore_changes = [ tags ]
   }

   lifecycle {
    prevent_destroy = true
  }


  tags = {
    Name = "Instance_with_Lifecycle_Rules"
  
}
}