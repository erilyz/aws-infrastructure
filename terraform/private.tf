/*
  Web Servers
*/
resource "aws_security_group" "base" {
  name        = "vpc_base"
  description = "Allow incoming ssh connections."

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.main_vpc_cidr}"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.main_vpc_cidr}"]
  }

  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "BaseSG"
  }
}

resource "aws_instance" "main" {
  ami               = "${lookup(var.ami, var.aws_region)}"
  availability_zone = "us-east-1b"
  instance_type     = "t2.micro"

  key_name                    = "${var.aws_key_name}"
  vpc_security_group_ids      = ["${aws_security_group.base.id}"]
  subnet_id                   = "${aws_subnet.main-public.id}"
  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name = "Main Server"
  }
}

resource "aws_eip" "main" {
  instance = "${aws_instance.main.id}"
  vpc      = true
}

//******************************************************************************
resource "aws_security_group" "basel" {
  name        = "vpc_basel"
  description = "Allow incoming ssh connections."

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.legacy_vpc_cidr}"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.legacy_vpc_cidr}"]
  }

  vpc_id = "${aws_vpc.legacy.id}"

  tags {
    Name = "BaseSG-l"
  }
}

resource "aws_instance" "legacy" {
  ami               = "${lookup(var.ami, var.aws_region)}"
  availability_zone = "us-east-1b"
  instance_type     = "t2.micro"

  key_name                    = "${var.aws_key_name}"
  vpc_security_group_ids      = ["${aws_security_group.basel.id}"]
  subnet_id                   = "${aws_subnet.legacy-public.id}"
  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name = "Legacy Server"
  }
}

resource "aws_eip" "legacy" {
  instance = "${aws_instance.legacy.id}"
  vpc      = true
}

# //*****************************************************************************
# resource "aws_security_group" "base1" {
#   name        = "vpc_base1"
#   description = "Allow incoming ssh connections."
#
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["${var.app1_vpc_cidr}"]
#   }
#
#   ingress {
#     from_port   = -1
#     to_port     = -1
#     protocol    = "icmp"
#     cidr_blocks = ["${var.app1_vpc_cidr}"]
#   }
#
#   vpc_id = "${aws_vpc.app1.id}"
#
#   tags {
#     Name = "BaseSG1"
#   }
# }
#
# resource "aws_instance" "app1" {
#   ami               = "${lookup(var.ami, var.aws_region)}"
#   availability_zone = "us-east-1b"
#   instance_type     = "t2.micro"
#
#   key_name                    = "${var.aws_key_name}"
#   vpc_security_group_ids      = ["${aws_security_group.base1.id}"]
#   subnet_id                   = "${aws_subnet.app1-public.id}"
#   associate_public_ip_address = true
#   source_dest_check           = false
#
#   tags {
#     Name = "app1 Server"
#   }
# }
#
# resource "aws_eip" "app1" {
#   instance = "${aws_instance.app1.id}"
#   vpc      = true
# }
#
# //*****************************************************************************
# resource "aws_security_group" "base2" {
#   name        = "vpc_base2"
#   description = "Allow incoming ssh connections."
#
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["${var.app2_vpc_cidr}"]
#   }
#
#   ingress {
#     from_port   = -1
#     to_port     = -1
#     protocol    = "icmp"
#     cidr_blocks = ["${var.app2_vpc_cidr}"]
#   }
#
#   vpc_id = "${aws_vpc.app2.id}"
#
#   tags {
#     Name = "BaseSG2"
#   }
# }
#
# resource "aws_instance" "app2" {
#   ami               = "${lookup(var.ami, var.aws_region)}"
#   availability_zone = "us-east-2b"
#   instance_type     = "t2.micro"
#
#   key_name                    = "${var.aws_key_name}"
#   vpc_security_group_ids      = ["${aws_security_group.base2.id}"]
#   subnet_id                   = "${aws_subnet.app2-public.id}"
#   associate_public_ip_address = true
#   source_dest_check           = false
#
#   tags {
#     Name = "app2 Server"
#   }
# }
#
# resource "aws_eip" "app2" {
#   instance = "${aws_instance.app2.id}"
#   vpc      = true
# }
#
# //*****************************************************************************
# resource "aws_security_group" "base3" {
#   name        = "vpc_base3"
#   description = "Allow incoming ssh connections."
#
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["${var.app3_vpc_cidr}"]
#   }
#
#   ingress {
#     from_port   = -1
#     to_port     = -1
#     protocol    = "icmp"
#     cidr_blocks = ["${var.app3_vpc_cidr}"]
#   }
#
#   vpc_id = "${aws_vpc.app3.id}"
#
#   tags {
#     Name = "BaseSG3"
#   }
# }
#
# resource "aws_instance" "app3" {
#   ami               = "${lookup(var.ami, var.aws_region)}"
#   availability_zone = "us-east-2b"
#   instance_type     = "t2.micro"
#
#   key_name                    = "${var.aws_key_name}"
#   vpc_security_group_ids      = ["${aws_security_group.base3.id}"]
#   subnet_id                   = "${aws_subnet.app3-public.id}"
#   associate_public_ip_address = true
#   source_dest_check           = false
#
#   tags {
#     Name = "app3 Server"
#   }
# }
#
# resource "aws_eip" "app3" {
#   instance = "${aws_instance.app3.id}"
#   vpc      = true
# }

