resource "aws_vpc" "app3" {
  cidr_block           = "${var.app3_vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "terraform-aws-app3-vpc"
  }
}

resource "aws_internet_gateway" "app3" {
  vpc_id = "${aws_vpc.app3.id}"
}

/*
  nat3 Instance
*/
resource "aws_security_group" "nat3" {
  name        = "app3_vpc_nat3"
  description = "Allow traffic to pass from the private subnet to the internet"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.app3_private_subnet_cidr}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.app3_private_subnet_cidr}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.app3_vpc_cidr}"]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.app3.id}"

  tags {
    Name = "nat3SG"
  }
}

resource "aws_instance" "nat3" {
  ami               = "ami-0f9c61b5a562a16af" # this is a special ami preconfigured to do nat3
  availability_zone = "us-east-2b"
  instance_type     = "m1.small"

  key_name                    = "${var.aws_key_name}"
  vpc_security_group_ids      = ["${aws_security_group.nat3.id}"]
  subnet_id                   = "${aws_subnet.app3-public.id}"
  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name = "app3 VPC nat3"
  }
}

resource "aws_eip" "nat3" {
  instance = "${aws_instance.nat3.id}"
  vpc      = true
}

/*
  Public Subnet
*/
resource "aws_subnet" "app3-public" {
  vpc_id = "${aws_vpc.app3.id}"

  cidr_block        = "${var.app3_public_subnet_cidr}"
  availability_zone = "us-east-2b"

  tags {
    Name = "Public Subnet"
  }
}

resource "aws_route_table" "app3-public" {
  vpc_id = "${aws_vpc.app3.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.app3.id}"
  }

  tags {
    Name = "Public Subnet"
  }
}

resource "aws_route_table_association" "app3-public" {
  subnet_id      = "${aws_subnet.app3-public.id}"
  route_table_id = "${aws_route_table.app3-public.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "app3-private" {
  vpc_id = "${aws_vpc.app3.id}"

  cidr_block        = "${var.app3_private_subnet_cidr}"
  availability_zone = "us-east-2b"

  tags {
    Name = "Private Subnet"
  }
}

resource "aws_route_table" "app3-private" {
  vpc_id = "${aws_vpc.app3.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = "${aws_instance.nat3.id}"
  }

  tags {
    Name = "Private Subnet"
  }
}

resource "aws_route_table_association" "app3-private" {
  subnet_id      = "${aws_subnet.app3-private.id}"
  route_table_id = "${aws_route_table.app3-private.id}"
}
