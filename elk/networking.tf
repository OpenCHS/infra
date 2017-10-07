resource "aws_vpc" "elk_vpc" {
  cidr_block = "172.100.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_classiclink = false
  tags {
    Name = "ELK VPC"
  }
}

resource "aws_subnet" "elk_subneta" {
  vpc_id = "${aws_vpc.elk_vpc.id}"
  cidr_block = "${cidrsubnet("${aws_vpc.elk_vpc.cidr_block}", 8, 1)}"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true
  tags {
    Name = "ELK Subnet A"
  }
}

resource "aws_subnet" "elk_subnetb" {
  vpc_id = "${aws_vpc.elk_vpc.id}"
  cidr_block = "${cidrsubnet("${aws_vpc.elk_vpc.cidr_block}", 8, 2)}"
  availability_zone = "${var.region}b"
  map_public_ip_on_launch = false
  tags {
    Name = "ELK Subnet B"
  }
}

resource "aws_internet_gateway" "elk_internet_gateway" {
  vpc_id = "${aws_vpc.elk_vpc.id}"
  tags {
    Name = "ELK Internet Gateway"
  }
}

resource "aws_route_table" "elk_route_table" {
  vpc_id = "${aws_vpc.elk_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.elk_internet_gateway.id}"
  }

  tags {
    Name = "ELK Route Table"
  }
}

resource "aws_route_table_association" "elk_external_main" {
  subnet_id = "${aws_subnet.elk_subneta.id}"
  route_table_id = "${aws_route_table.elk_route_table.id}"
}

resource "aws_route_table_association" "elk_external_secondary" {
  subnet_id = "${aws_subnet.elk_subnetb.id}"
  route_table_id = "${aws_route_table.elk_route_table.id}"
}

data "aws_route53_zone" "openchs" {
  name = "openchs.org"
  private_zone = false
}

