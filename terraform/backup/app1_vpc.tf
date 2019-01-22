resource "aws_vpc" "app1" {
  cidr_block           = "${var.app1_vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "terraform-aws-app1-vpc"
  }
}

resource "aws_internet_gateway" "app1" {
  vpc_id = "${aws_vpc.app1.id}"
}

/*
  nat1 Instance
*/
resource "aws_security_group" "nat1" {
  name        = "app1_vpc_nat1"
  description = "Allow traffic to pass from the private subnet to the internet"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.app1_private_subnet_cidr}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.app1_private_subnet_cidr}"]
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
    cidr_blocks = ["${var.app1_vpc_cidr}"]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.app1.id}"

  tags {
    Name = "nat1SG"
  }
}

resource "aws_instance" "nat1" {
  ami               = "ami-0f9c61b5a562a16af" # this is a special ami preconfigured to do nat1
  availability_zone = "us-east-2b"
  instance_type     = "m1.small"

  key_name                    = "${var.aws_key_name}"
  vpc_security_group_ids      = ["${aws_security_group.nat1.id}"]
  subnet_id                   = "${aws_subnet.app1-public.id}"
  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name = "app1 VPC nat1"
  }
}

resource "aws_eip" "nat1" {
  instance = "${aws_instance.nat1.id}"
  vpc      = true
}

/*
  Public Subnet
*/
resource "aws_subnet" "app1-public" {
  vpc_id = "${aws_vpc.app1.id}"

  cidr_block        = "${var.app1_public_subnet_cidr}"
  availability_zone = "us-east-2b"

  tags {
    Name = "Public Subnet"
  }
}

resource "aws_route_table" "app1-public" {
  vpc_id = "${aws_vpc.app1.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.app1.id}"
  }

  tags {
    Name = "Public Subnet"
  }
}

resource "aws_route_table_association" "app1-public" {
  subnet_id      = "${aws_subnet.app1-public.id}"
  route_table_id = "${aws_route_table.app1-public.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "app1-private" {
  vpc_id = "${aws_vpc.app1.id}"

  cidr_block        = "${var.app1_private_subnet_cidr}"
  availability_zone = "us-east-2b"

  tags {
    Name = "Private Subnet"
  }
}

resource "aws_route_table" "app1-private" {
  vpc_id = "${aws_vpc.app1.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = "${aws_instance.nat1.id}"
  }

  tags {
    Name = "Private Subnet"
  }
}

resource "aws_route_table_association" "app1-private" {
  subnet_id      = "${aws_subnet.app1-private.id}"
  route_table_id = "${aws_route_table.app1-private.id}"
}
