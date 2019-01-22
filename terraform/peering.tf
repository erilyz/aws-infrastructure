// VPC Peering agreements from MAIN to each
resource "aws_vpc_peering_connection" "main2legacy" {
  //peer_owner_id = "${var.peer_owner_id}"
  peer_vpc_id = "${aws_vpc.legacy.id}"
  vpc_id      = "${aws_vpc.main.id}"
  auto_accept = true

  tags = {
    Name = "VPC Peering between main and legacy"
  }
}

# resource "aws_vpc_peering_connection" "main2app1" {
#   //peer_owner_id = "${var.peer_owner_id}"
#   peer_vpc_id = "${aws_vpc.app1.id}"
#   vpc_id      = "${aws_vpc.main.id}"
#   auto_accept = true
#
#   tags = {
#     Name = "VPC Peering between main and app1"
#   }
# }
#
# resource "aws_vpc_peering_connection" "main2app2" {
#   //peer_owner_id = "${var.peer_owner_id}"
#   peer_vpc_id = "${aws_vpc.app2.id}"
#   vpc_id      = "${aws_vpc.main.id}"
#   auto_accept = true
#
#   tags = {
#     Name = "VPC Peering between main and app2"
#   }
# }
#
# resource "aws_vpc_peering_connection" "main2app3" {
#   //peer_owner_id = "${var.peer_owner_id}"
#   peer_vpc_id = "${aws_vpc.app3.id}"
#   vpc_id      = "${aws_vpc.main.id}"
#   auto_accept = true
#
#   tags = {
#     Name = "VPC Peering between main and app3"
#   }
# }

