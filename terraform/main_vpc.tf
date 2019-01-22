resource "aws_vpc" "main" {
  cidr_block           = "${var.main_vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "terraform-aws-main-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
}

/*
  natm Instance
*/
resource "aws_security_group" "natm" {
  name        = "main_vpc_natm"
  description = "Allow traffic to pass from the private subnet to the internet"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.main_private_subnet_cidr}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.main_private_subnet_cidr}"]
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
    cidr_blocks = ["${var.main_vpc_cidr}"]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "natmSG"
  }
}

resource "aws_instance" "natm" {
  ami               = "ami-0422d936d535c63b1" # this is a special ami preconfigured to do natm
  availability_zone = "us-east-1b"
  instance_type     = "m1.small"

  key_name                    = "${var.aws_key_name}"
  vpc_security_group_ids      = ["${aws_security_group.natm.id}"]
  subnet_id                   = "${aws_subnet.main-public.id}"
  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name = "main VPC natm"
  }
}

resource "aws_eip" "natm" {
  instance = "${aws_instance.natm.id}"
  vpc      = true
}

/*
  Public Subnet
*/
resource "aws_subnet" "main-public" {
  vpc_id = "${aws_vpc.main.id}"

  cidr_block        = "${var.main_public_subnet_cidr}"
  availability_zone = "us-east-1b"

  tags {
    Name = "Public Subnet"
  }
}

resource "aws_route_table" "main-public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "Public Subnet"
  }
}

resource "aws_route_table_association" "main-public" {
  subnet_id      = "${aws_subnet.main-public.id}"
  route_table_id = "${aws_route_table.main-public.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "main-private" {
  vpc_id = "${aws_vpc.main.id}"

  cidr_block        = "${var.main_private_subnet_cidr}"
  availability_zone = "us-east-1b"

  tags {
    Name = "Private Subnet"
  }
}

resource "aws_route_table" "main-private" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = "${aws_instance.natm.id}"
  }

  tags {
    Name = "Private Subnet"
  }
}

resource "aws_route_table_association" "main-private" {
  subnet_id      = "${aws_subnet.main-private.id}"
  route_table_id = "${aws_route_table.main-private.id}"
}
