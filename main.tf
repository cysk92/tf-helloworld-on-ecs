provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available_zones" {
  state = "available"
}
