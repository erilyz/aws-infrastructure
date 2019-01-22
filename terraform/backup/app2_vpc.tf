resource "aws_vpc" "app2" {
  cidr_block           = "${var.app2_vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "terraform-aws-app2-vpc"
  }
}

resource "aws_internet_gateway" "app2" {
  vpc_id = "${aws_vpc.app2.id}"
}

/*
  nat2 Instance
*/
resource "aws_security_group" "nat2" {
  name        = "app2_vpc_nat2"
  description = "Allow traffic to pass from the private subnet to the internet"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.app2_private_subnet_cidr}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.app2_private_subnet_cidr}"]
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
    cidr_blocks = ["${var.app2_vpc_cidr}"]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.app2.id}"

  tags {
    Name = "nat2SG"
  }
}

resource "aws_instance" "nat2" {
  ami               = "ami-0f9c61b5a562a16af" # this is a special ami preconfigured to do nat2
  availability_zone = "us-east-2b"
  instance_type     = "m1.small"

  key_name                    = "${var.aws_key_name}"
  vpc_security_group_ids      = ["${aws_security_group.nat2.id}"]
  subnet_id                   = "${aws_subnet.app2-public.id}"
  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name = "app2 VPC nat2"
  }
}

resource "aws_eip" "nat2" {
  instance = "${aws_instance.nat2.id}"
  vpc      = true
}

/*
  Public Subnet
*/
resource "aws_subnet" "app2-public" {
  vpc_id = "${aws_vpc.app2.id}"

  cidr_block        = "${var.app2_public_subnet_cidr}"
  availability_zone = "us-east-2b"

  tags {
    Name = "Public Subnet"
  }
}

resource "aws_route_table" "app2-public" {
  vpc_id = "${aws_vpc.app2.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.app2.id}"
  }

  tags {
    Name = "Public Subnet"
  }
}

resource "aws_route_table_association" "app2-public" {
  subnet_id      = "${aws_subnet.app2-public.id}"
  route_table_id = "${aws_route_table.app2-public.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "app2-private" {
  vpc_id = "${aws_vpc.app2.id}"

  cidr_block        = "${var.app2_private_subnet_cidr}"
  availability_zone = "us-east-2b"

  tags {
    Name = "Private Subnet"
  }
}

resource "aws_route_table" "app2-private" {
  vpc_id = "${aws_vpc.app2.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = "${aws_instance.nat2.id}"
  }

  tags {
    Name = "Private Subnet"
  }
}

resource "aws_route_table_association" "app2-private" {
  subnet_id      = "${aws_subnet.app2-private.id}"
  route_table_id = "${aws_route_table.app2-private.id}"
}
