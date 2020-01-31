# Define our VPC

resource "aws_vpc" "default" {
   cidr_block = "${var.vpc_cidr}"
   enable_dns_hostnames = true
      tags = {
        Name = "production-vpc"
      }
}

# create Public Subnet-1

resource "aws_subnet" "public-subnet-1" {
   vpc_id = "${aws_vpc.default.id}"
   cidr_block = "${var.public_subnet_1_cidr}"
   availability_zone = "ap-south-1a"
   tags = {
     Name = "public-subnet-1"
   }
}

# create Public Subnet-2

resource "aws_subnet" "public-subnet-2" {
   vpc_id = "${aws_vpc.default.id}"
   cidr_block = "${var.public_subnet_2_cidr}"
   availability_zone = "ap-south-1b"
   tags = {
     Name = "public-subnet-2"
   }
}

# create Private Subnet1

resource "aws_subnet" "private-subnet-1" {
   vpc_id = "${aws_vpc.default.id}"
   cidr_block = "${var.private_subnet_1_cidr}"
   availability_zone = "ap-south-1a"
   tags = {
     Name = "private-subnet-1"
   }
}

# create Private Subnet2

resource "aws_subnet" "private-subnet-2" {
   vpc_id = "${aws_vpc.default.id}"
   cidr_block = "${var.private_subnet_2_cidr}"
   availability_zone = "ap-south-1b"
   tags = {
     Name = "private-subnet-2"
   }
}


# create a public and Private Route Table

resource "aws_route_table" "public-route-table" {
   vpc_id = "${aws_vpc.default.id}"
   tags = {
     Name = "Public-Route-Table"
   }
}

resource "aws_route_table" "private-route-table" {
   vpc_id = "${aws_vpc.default.id}"
   tags = {
     Name = "Private-Route-Table"
   }
}

# Associating Route Tables With Public Subnets

resource "aws_route_table_association" "public-subnet-1-association" {
    route_table_id = "${aws_route_table.public-route-table.id}"
    subnet_id = "${aws_subnet.public-subnet-1.id}"
}

resource "aws_route_table_association" "public-subnet-2-association" {
    route_table_id = "${aws_route_table.public-route-table.id}"
    subnet_id = "${aws_subnet.public-subnet-2.id}"
}

# Associating Route Tables With Private Subnets

resource "aws_route_table_association" "private-subnet-1-association" {
        route_table_id = "${aws_route_table.private-route-table.id}"
        subnet_id = "${aws_subnet.private-subnet-1.id}"
}

resource "aws_route_table_association" "private-subnet-2-association" {
        route_table_id = "${aws_route_table.private-route-table.id}"
        subnet_id = "${aws_subnet.private-subnet-2.id}"
}


# creating a Elastic IP For Nat Gateway

resource "aws_eip" "elastic-ip-for-nat-gw" {
  vpc = true
  tags = {
    Name = "Production-EIP"
  }
}

# creating a Nat-Gateway And Adding to Route Table

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.elastic-ip-for-nat-gw.id}"
  subnet_id = "${aws_subnet.public-subnet-1.id}"
    tags = {
      Name = "Production-NAT-GW"
  }
}

resource "aws_route" "nat-gw-route" {
  route_table_id = "${aws_route_table.private-route-table.id}"
  nat_gateway_id = "${aws_nat_gateway.nat-gw.id}"
  destination_cidr_block = "0.0.0.0/0"
}

# creating an Internet Gateway(IGW) and adding to Route Table
resource "aws_internet_gateway" "production-igw" {
 vpc_id = "${aws_vpc.default.id}"
 tags = {
   Name = "Production-IGW"
 }
}

resource "aws_route" "public-internet-gw-route" {
  route_table_id = "${aws_route_table.public-route-table.id}"
  gateway_id = "${aws_internet_gateway.production-igw.id}"
  destination_cidr_block = "0.0.0.0/0"
}

# Now creating Security Group for Frontend Webserver

resource "aws_security_group" "sgweb" {
  name = "web-server-sg"
  description = "Allow incoming Http and HTTPS connections & SSH from office ISP Public IP Only"
  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# ssh is allowed only to MY ISP
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["14.98.228.11/32"]
  }
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["223.26.31.162/32"]
  }


  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.default.id}"
  tags = {
    Name = "web-server-sg"
  }
}

# Define the Security Group For Private Subnet Database
resource "aws_security_group" "sgdb"{
  name = "security-group-database"
  description = "Allow traffic from public subnet"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.default.id}"

  tags = {
    Name = "security-group-database"
  }
}

# Define SG for Backed Application Suppose I have tomcat which is running on tomcat

resource "aws_security_group" "backend"{
   name = "security-group-backend-app"
   description = "Allow traffic from public subnet"


  ingress {
    from_port = 8806
    to_port = 8806
    protocol = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.default.id}"

  tags = {
    Name = "sg-backend-application"
  }
}

