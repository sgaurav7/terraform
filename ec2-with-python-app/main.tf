# VPC creation
resource "aws_vpc" "myvpc" {
    cidr_block = var.vpc_cidr
}

# Public Subnet creation
resource "aws_subnet" "public-subnet" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true
}

# Private Subnet creation
resource "aws_subnet" "private-subnet" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1b"
    map_public_ip_on_launch = true
}

# Internet Gateway creation and attaching to the VPC
resource "aws_internet_gateway" "myigw" {
     vpc_id = aws_vpc.myvpc.id
}

# Creating route table for the public subnet and add routr to the internet via internet gateway
resource "aws_route_table" "myrt" {
     vpc_id = aws_vpc.myvpc.id

     route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myigw.id
     }
}

# Doing subnet association in the above created route table and associating public subnet which can reach internet
resource "aws_route_table_association" "rt1" {
    subnet_id = aws_subnet.public-subnet.id
    route_table_id = aws_route_table.myrt.id
}

# Creating Security group in which allowing 80 and 22 port
resource "aws_security_group" "web-sg" {
    name = "web"
    vpc_id = aws_vpc.myvpc.id

    ingress {
        description = "HTTP from VPC"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Web-sg"
    }
  
}

# Creating key-pair for the server
resource "aws_key_pair" "example-key" {
    key_name = "myserverkey"
    public_key = file("~/.ssh/id_rsa.pub")
}

# Creating EC2 instance
resource "aws_instance" "web-server" {
     instance_type = var.instance_type
     ami = var.ami_id
     key_name = aws_key_pair.example-key.key_name
     subnet_id = aws_subnet.public-subnet.id
     security_groups = [aws_security_group.web-sg.id]


     connection {
       type = "ssh"
       user = "ec2-user"
       private_key = file("~/.ssh/id_rsa")
       host = self.public_ip
     }

    # File provisioner to copy a file from local to the remote EC2 instance
     provisioner "file" {
        source = "app.py"
        destination = "/home/ec2-user/app.py"       
     }

     provisioner "remote-exec" {
       inline = [ 
      "echo 'Hello from the remote instance'",
      "sudo yum update -y",  # Update package lists (for ubuntu)
      "sudo yum install -y python3-pip",  # Example package installation
      "sudo cd /root",
      "sudo pip3 install flask",
      "sudo nohup python3 app.py &",        
]
     }

}
