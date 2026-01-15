variable "ami_id" {
  description = "The ID of the AMI to use for the instance"
  default     = "ami-07ff62358b87c7116" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  type        = string
}
variable "instance_type" {
  description = "The type of instance to use"
  default     = "t2.micro"
  type        = string
}
variable "instance_name" {
  description = "The name tag for the EC2 instance"
  default     = "MyEC2Instance"
  type        = string
}

variable "region" {
  description = "The AWS region to deploy resources in"
  default     = "us-east-1"
  type        = string
}

