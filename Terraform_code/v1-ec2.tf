#Creating Ec2 instance with Security group andd VPC

provider "aws" {
  region ="us-east-1"
}

# creating an EC2 Instance
resource "aws_instance" "demo_server" {
#     tags = {
#     Name = "Demo_server"
#   }
    ami= "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"
    key_name = "new_key"
    # security_groups = ["demo-sg"]
    vpc_security_group_ids = [ aws_security_group.demo-sg.id ]
    subnet_id = aws_subnet.demo-public_subent_01.id
    for_each = toset(["Jenkins-master", "Build-slave", "Ansible"])
    tags = {
     Name = "${each.key}"
   }
  
}

# Creating  a Security Group
resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH Access"
  vpc_id = aws_vpc.demo-vpc.id


  ingress {
    description      = "SSH Access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
   cidr_blocks      = ["0.0.0.0/0"]
 
  }

  ingress {
    description      = "Jenkins-port"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
   cidr_blocks      = ["0.0.0.0/0"]
 
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SSH-Acess"
  }
}

#creating a VPC
resource "aws_vpc" "demo-vpc" {
   cidr_block = "10.1.0.0/16"
       tags = {
        Name = "demo-vpc"
     }
   }

# creating a subnet

resource "aws_subnet" "demo-public_subent_01" {
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = "10.1.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
      Name = "demo-public_subent_01"
    }
}

resource "aws_subnet" "demo-public_subent_02" {
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = "10.1.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1b"
    tags = {
      Name = "demo-public_subent_02"
    }
}

#Creating an Internet Gateway 
resource "aws_internet_gateway" "demo-igw" {
    vpc_id = aws_vpc.demo-vpc.id
    tags = {
      Name = "demo-igw"
    }
}

# Create a route table 
resource "aws_route_table" "demo-public-rt" {
    vpc_id = aws_vpc.demo-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.demo-igw.id
    }
    tags = {
      Name = "demo-public-rt"
    }
}

# Associate subnet with route table

resource "aws_route_table_association" "demo-rta-public-subent-1" {
    subnet_id = aws_subnet.demo-public_subent_01.id
    route_table_id = aws_route_table.demo-public-rt.id
}

resource "aws_route_table_association" "demo-rta-public-subent-2" {
    subnet_id = aws_subnet.demo-public_subent_02.id
    route_table_id = aws_route_table.demo-public-rt.id
}