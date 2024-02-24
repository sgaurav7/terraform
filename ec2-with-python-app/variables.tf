variable "vpc_cidr" {
    description = "CIDR value of VPC"
}

variable "ami_id" {
    description = "AMI ID"
    type = string 
}

variable "instance_type" {
     description = "EC2 instance type"
     type = string
}