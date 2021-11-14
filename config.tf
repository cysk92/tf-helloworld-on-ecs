terraform {
  backend "s3" {
    bucket = "pablo-techtests"
    key    = "kantox/ecs/terraform.tfstate"
    region = "us-east-1"
  }
}
