terraform {
  backend "s3" {
    bucket = "mauri-terraform-state"
    key    = "app/vpc.json"
    region = "us-east-1"
    dynamodb_table = "mauri-terraform-state" # Partition key = LockID
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.16.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    Name = "mojix-vpc"
  }
}


