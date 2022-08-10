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

resource "aws_subnet" "subnets" {
  for_each   = local.subnets
  vpc_id     = aws_vpc.main.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.az

  tags = {
    Name = each.key
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "mojix-igw"
  }
}

resource "aws_route_table" "web_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "web_rt"
  }
}

resource "aws_route_table_association" "web_rt_association" {
  for_each = {
    "sn-web-A"= local.subnets.sn-web-A
    "sn-web-B"= local.subnets.sn-web-B
    "sn-web-C"= local.subnets.sn-web-C
  }
  subnet_id      = aws_subnet.subnets["${each.key}"].id
  route_table_id = aws_route_table.web_rt.id
}
