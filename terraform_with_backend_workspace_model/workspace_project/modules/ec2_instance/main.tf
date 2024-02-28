resource "aws_instance" "my-server" {
    ami = var.ami
    instance_type = var.instance_type
    tags = {
      name = "my-server"
    }
}