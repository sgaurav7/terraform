terraform {
  backend "s3" {
     bucket = "mybucket8423"
     region = "ap-south-1"
     key = "terraform/terraform.tfstate"
     dynamodb_table = "terraform_lock"
  }
}