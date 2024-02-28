provider "aws" {
    region = "ap-south-1"
}

resource "aws_s3_bucket" "backend_bucket" {
     bucket = "mybucket8423"
     
}