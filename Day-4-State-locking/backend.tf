terraform {
  backend "s3" {
    bucket = "nagendraindhuja143"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}