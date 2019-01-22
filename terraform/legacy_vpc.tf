resource "aws_vpc" "legacy" {
  cidr_block           = "${var.legacy_vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "terraform-aws-legacy-vpc"
  }
}

resource "aws_internet_gateway" "legacy" {
  vpc_id = "${aws_vpc.legacy.id}"
}

/*
  natl Instance
*/
resource "aws_security_group" "natl" {
  name        = "legacy_vpc_natl"
  description = "Allow traffic to pass from the private subnet to the internet"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.legacy_private_subnet_cidr}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.legacy_private_subnet_cidr}"]
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
    cidr_blocks = ["${var.legacy_vpc_cidr}"]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.legacy.id}"

  tags {
    Name = "natlSG"
  }
}

resource "aws_instance" "natl" {
  ami               = "ami-0422d936d535c63b1" # this is a special ami preconfigured to do natl
  availability_zone = "us-east-1b"
  instance_type     = "m1.small"

  key_name                    = "${var.aws_key_name}"
  vpc_security_group_ids      = ["${aws_security_group.natl.id}"]
  subnet_id                   = "${aws_subnet.legacy-public.id}"
  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name = "legacy VPC natl"
  }
}

resource "aws_eip" "natl" {
  instance = "${aws_instance.natl.id}"
  vpc      = true
}

/*
  Public Subnet
*/
resource "aws_subnet" "legacy-public" {
  vpc_id = "${aws_vpc.legacy.id}"

  cidr_block        = "${var.legacy_public_subnet_cidr}"
  availability_zone = "us-east-1b"

  tags {
    Name = "Public Subnet"
  }
}

resource "aws_route_table" "legacy-public" {
  vpc_id = "${aws_vpc.legacy.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.legacy.id}"
  }

  tags {
    Name = "Public Subnet"
  }
}

resource "aws_route_table_association" "legacy-public" {
  subnet_id      = "${aws_subnet.legacy-public.id}"
  route_table_id = "${aws_route_table.legacy-public.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "legacy-private" {
  vpc_id = "${aws_vpc.legacy.id}"

  cidr_block        = "${var.legacy_private_subnet_cidr}"
  availability_zone = "us-east-1b"

  tags {
    Name = "Private Subnet"
  }
}

resource "aws_route_table" "legacy-private" {
  vpc_id = "${aws_vpc.legacy.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = "${aws_instance.natl.id}"
  }

  tags {
    Name = "Private Subnet"
  }
}

resource "aws_route_table_association" "legacy-private" {
  subnet_id      = "${aws_subnet.legacy-private.id}"
  route_table_id = "${aws_route_table.legacy-private.id}"
}
