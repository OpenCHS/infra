resource "aws_vpc" "reportingjaspervpc" {
  cidr_block           = "172.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_classiclink   = false

  tags {
    Name = "Reporting Jasper"
  }
}

resource "aws_subnet" "reportingjaspersubneta" {
  vpc_id                  = "${aws_vpc.reportingjaspervpc.id}"
  cidr_block              = "${cidrsubnet("${aws_vpc.reportingjaspervpc.cidr_block}", 8, 1)}"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags {
    Name = "Reporting Jasper Subnet A"
  }
}

resource "aws_subnet" "reportingjaspersubnetb" {
  vpc_id                  = "${aws_vpc.reportingjaspervpc.id}"
  cidr_block              = "${cidrsubnet("${aws_vpc.reportingjaspervpc.cidr_block}", 8, 2)}"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false

  tags {
    Name = "Reporting Jasper Subnet B"
  }
}

resource "aws_internet_gateway" "reporting_jasper_internet_gateway" {
  vpc_id = "${aws_vpc.reportingjaspervpc.id}"
}

resource "aws_route_table" "reporting_jasper_route_table" {
  vpc_id = "${aws_vpc.reportingjaspervpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.reporting_jasper_internet_gateway.id}"
  }

  lifecycle {
    ignore_changes = [
      "route",
    ]
  }

  tags {
    Name = "Reporting Jasper Route Table"
  }
}

resource "aws_route_table_association" "reporting_jasper_external_main" {
  subnet_id      = "${aws_subnet.reportingjaspersubneta.id}"
  route_table_id = "${aws_route_table.reporting_jasper_route_table.id}"
}

resource "aws_route_table_association" "reporting_jasper_external_secondary" {
  subnet_id      = "${aws_subnet.reportingjaspersubnetb.id}"
  route_table_id = "${aws_route_table.reporting_jasper_route_table.id}"
}

resource "aws_security_group" "reporting_jasper_server_sg" {
  name        = "reporting_jasper_server_sg"
  description = "Allowed Ports"
  vpc_id      = "${aws_vpc.reportingjaspervpc.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = 0
    to_port   = "8080"
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

//resource "aws_security_group" "reporting_jasper_db_sg" {
//  name        = "db-sg"
//  description = "Allowed Ports On Db"
//  vpc_id      = "${aws_vpc.reportingjaspervpc.id}"
//
//  ingress {
//    from_port = 0
//    to_port   = 5432
//    protocol  = "tcp"
//
//    cidr_blocks = [
//      "${aws_vpc.reportingjaspervpc.cidr_block}",
//    ]
//  }
//
//  egress {
//    from_port = 0
//    to_port   = 0
//    protocol  = "-1"
//
//    cidr_blocks = [
//      "${aws_vpc.reportingjaspervpc.cidr_block}",
//    ]
//  }
//}

//resource "aws_security_group" "reporting_jasper_elb_sg" {
//  name        = "elb-sg"
//  description = "Allowed Ports on ELB"
//  vpc_id      = "${aws_vpc.reportingjaspervpc.id}"
//
//  ingress {
//    from_port = 443
//    to_port   = 443
//    protocol  = "tcp"
//
//    cidr_blocks = [
//      "0.0.0.0/0",
//    ]
//  }
//
//  ingress {
//    from_port = 0
//    to_port   = 0
//    protocol  = "-1"
//
//    cidr_blocks = [
//      "${aws_vpc.reportingjaspervpc.cidr_block}",
//    ]
//  }
//
//  egress {
//    from_port = 0
//    to_port   = 0
//    protocol  = "-1"
//
//    cidr_blocks = [
//      "0.0.0.0/0",
//    ]
//  }
//
//  depends_on = [
//    "aws_internet_gateway.reporting_jasper_internet_gateway",
//  ]
//}

data "aws_route53_zone" "openchs" {
  name         = "openchs.org"
  private_zone = false
}
