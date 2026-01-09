terraform {
  backend "s3" {
    bucket = "nagendraindhuja143"
    key    = "terraform.tfstate"
    region = "us-east-1"
    #use_lockfile = true >1.19 version above we can use s3 state locking
    dynamodb_table = "nagendra"
    encrypt = true
    
  }
}