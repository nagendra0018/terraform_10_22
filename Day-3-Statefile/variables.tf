variable "ami_id" {
  description = "The ID of the AMI to use for the instance"
  default = ""
  type = string

}
variable "instance_type" {
  description = "The type of instance to use"
  default = ""
  type = string

}
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default = ""
  type = string

}
variable "subnet_cidr" {
  description = "The CIDR block for the Subnet"
  default = ""
  type = string

}
variable "availability_zone" {
  description = "The availability zone for the Subnet"
  default = ""
  type = string

}
variable "instance_name" {
  description = "The name tag for the EC2 instance"
  default = ""
  type = string

}
variable "vpc_name" {
  description = "The name tag for the VPC"
  default = ""
  type = string

}
variable "subnet_name" {
  description = "The name tag for the Subnet"
  default = ""
  type = string

}
variable "region" {
  description = "The AWS region to deploy resources in"
  default = ""
  type = string

}


