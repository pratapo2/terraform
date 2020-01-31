# define webserver inside the public subnet

resource "aws_instance" "wb" {
 ami = "${var.ami}"
 instance_type = "t2.micro"
 key_name = "champ"
 subnet_id = "${aws_subnet.public-subnet-1.id}"
 vpc_security_group_ids = ["${aws_security_group.sgweb.id}"] 
 associate_public_ip_address = true
 source_dest_check = false

 tags = {
   Name = "webserver"
 }
}

# Define Backend inside the Private Subnet

resource "aws_instance" "backend" {
 ami = "${var.ami}"
 instance_type = "t2.micro"
 key_name = "champ"
 subnet_id = "${aws_subnet.private-subnet-1.id}"
 vpc_security_group_ids = ["${aws_security_group.backend.id}"]
 source_dest_check = false

 tags = {
   Name = "backend"
 }
}

# Define database inside the private Subnet

resource "aws_instance" "db" {
 ami = "${var.ami}"
 instance_type = "t2.micro"
 key_name = "champ"
 subnet_id = "${aws_subnet.private-subnet-2.id}"
 vpc_security_group_ids = ["${aws_security_group.sgdb.id}"]
 source_dest_check = false

 tags = {
   Name = "database"
 }
}


