resource "aws_vpc" "vpc" {
  cidr_block           = "${lookup(var.cidr_map, var.environment, "172.1.0.0/16")}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_classiclink   = false

  tags {
    Name = "${var.environment} VPC"
  }
}

data "aws_vpc" "accepter" {
  cidr_block = "172.10.0.0/16"

  tags {
    Name = "Reporting"
  }
}

data "aws_vpc" "jasper" {
  cidr_block = "172.11.0.0/16"

  tags {
    Name = "Reporting Jasper VPC"
  }
}

data "aws_caller_identity" "current" {}

data "aws_route_table" "accepter_route_table" {
  vpc_id = "${data.aws_vpc.accepter.id}"

  tags {
    Name = "Reporting Route Table"
  }
}

data "aws_route_table" "jasper_route_table" {
  vpc_id = "${data.aws_vpc.jasper.id}"

  tags {
    Name = "Reporting Jasper Route Table"
  }
}

resource "aws_vpc_peering_connection" "environment_to_reporting" {
  peer_owner_id = "${data.aws_caller_identity.current.account_id}"
  peer_vpc_id   = "${data.aws_vpc.accepter.id}"
  vpc_id        = "${aws_vpc.vpc.id}"
  auto_accept   = true

  tags {
    Name = "${var.environment} To Reporting VPC Peering"
  }
}

resource "aws_vpc_peering_connection" "environment_to_jasper_reporting" {
  peer_owner_id = "${data.aws_caller_identity.current.account_id}"
  peer_vpc_id   = "${data.aws_vpc.jasper.id}"
  vpc_id        = "${aws_vpc.vpc.id}"
  auto_accept   = true

  tags {
    Name = "${var.environment} To Reporting Jasper VPC Peering"
  }
}

resource "aws_route" "reporting_to_environment" {
  route_table_id            = "${data.aws_route_table.accepter_route_table.route_table_id}"
  destination_cidr_block    = "${aws_vpc.vpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.environment_to_reporting.id}"
}

resource "aws_route" "reporting_jasper_to_environment" {
  route_table_id            = "${data.aws_route_table.jasper_route_table.route_table_id}"
  destination_cidr_block    = "${aws_vpc.vpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.environment_to_jasper_reporting.id}"
}

resource "aws_subnet" "subneta" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet("${aws_vpc.vpc.cidr_block}", 8, 1)}"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.environment} Subnet A"
  }
}

resource "aws_subnet" "subnetb" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet("${aws_vpc.vpc.cidr_block}", 8, 2)}"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false

  tags {
    Name = "${var.environment} Subnet B"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment} Internet Gateway"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }

  route {
    cidr_block                = "${data.aws_vpc.accepter.cidr_block}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.environment_to_reporting.id}"
  }

  route {
    cidr_block                = "${data.aws_vpc.jasper.cidr_block}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.environment_to_jasper_reporting.id}"
  }

  route {
    cidr_block                = "${aws_vpc.avni_alb_vpc.cidr_block}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.avni_alb_to_env.id}"
  }

  depends_on = [
    "aws_vpc_peering_connection.environment_to_reporting",
    "aws_vpc_peering_connection.environment_to_jasper_reporting",
  ]

  tags {
    Name = "${var.environment} Route Table"
  }
}

resource "aws_route_table_association" "external_main" {
  subnet_id      = "${aws_subnet.subneta.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}

resource "aws_route_table_association" "external_secondary" {
  subnet_id      = "${aws_subnet.subnetb.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}

resource "aws_security_group" "server_sg" {
  name        = "server-sg"
  description = "Allowed Ports"
  vpc_id      = "${aws_vpc.vpc.id}"

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
    to_port   = "${var.server_port}"
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_vpc.vpc.cidr_block}",
      "${data.aws_vpc.accepter.cidr_block}",
    ]
  }

  ingress {
    from_port = "${var.server_port}"
    to_port   = "${var.server_port}"
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_vpc.avni_alb_vpc.cidr_block}",
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

resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allowed Ports On Db"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 0
    to_port   = 5432
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_vpc.vpc.cidr_block}",
      "${data.aws_vpc.accepter.cidr_block}",
      "${data.aws_vpc.jasper.cidr_block}",
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "${aws_vpc.vpc.cidr_block}",
      "${data.aws_vpc.accepter.cidr_block}",
    ]
  }
}

resource "aws_security_group" "elb_sg" {
  name        = "elb-sg"
  description = "Allowed Ports on ELB"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "${aws_vpc.vpc.cidr_block}",
      "${data.aws_vpc.accepter.cidr_block}",
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

  depends_on = [
    "aws_internet_gateway.internet_gateway",
  ]
}

data "aws_route53_zone" "openchs" {
  name         = "openchs.org"
  private_zone = false
}

resource "aws_vpc" "avni_alb_vpc" {
  cidr_block           = "${lookup(var.cidr_map, "avni_alb", "172.1.0.0/16")}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "Avni ALB VPC"
  }
}

resource "aws_subnet" "avni_alb_subneta" {
  vpc_id                  = "${aws_vpc.avni_alb_vpc.id}"
  cidr_block              = "${cidrsubnet("${aws_vpc.avni_alb_vpc.cidr_block}", 8, 1)}"
  availability_zone       = "${var.region}a"

  tags {
    Name = "Avni ALB Subnet A"
  }
}

resource "aws_subnet" "avni_alb_subnetb" {
  vpc_id                  = "${aws_vpc.avni_alb_vpc.id}"
  cidr_block              = "${cidrsubnet("${aws_vpc.avni_alb_vpc.cidr_block}", 8, 2)}"
  availability_zone       = "${var.region}b"

  tags {
    Name = "Avni ALB Subnet B"
  }
}

resource "aws_internet_gateway" "avni_alb_internet_gateway" {
  vpc_id = "${aws_vpc.avni_alb_vpc.id}"

  tags {
    Name = "Avni ALB Internet Gateway"
  }
}

resource "aws_vpc_peering_connection" "avni_alb_to_env" {
  peer_owner_id = "${data.aws_caller_identity.current.account_id}"
  vpc_id        = "${aws_vpc.avni_alb_vpc.id}"
  peer_vpc_id   = "${aws_vpc.vpc.id}"
  auto_accept   = true

  tags {
    Name = "Avni ALB VPC -> ${var.environment}"
  }
}

resource "aws_route_table" "avn_alb_route_table" {
  vpc_id = "${aws_vpc.avni_alb_vpc.id}"

  tags {
    Name ="Avni ALB Route Table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.avni_alb_internet_gateway.id}"
  }

  route {
    vpc_peering_connection_id = "${aws_vpc_peering_connection.avni_alb_to_env.id}"
    cidr_block = "${aws_vpc.vpc.cidr_block}"
  }
}

resource "aws_route_table_association" "avni_route_table_assoc_a" {
  subnet_id      = "${aws_subnet.avni_alb_subneta.id}"
  route_table_id = "${aws_route_table.avn_alb_route_table.id}"
}

resource "aws_route_table_association" "avni_route_table_assoc_b" {
  subnet_id      = "${aws_subnet.avni_alb_subnetb.id}"
  route_table_id = "${aws_route_table.avn_alb_route_table.id}"
}

resource "aws_alb_target_group" "avni_alb_env_target_group" {
  name = "Avni ALB ${var.environment} Target Group"
  target_type = "ip"
  protocol = "HTTP"
  port = "${var.server_port}"
  vpc_id = "${aws_vpc.avni_alb_vpc.id}"
  health_check {
    protocol = "HTTP"
    path = "/ping"
  }
}

resource "aws_alb_target_group_attachment" "avni_alb_env_target_group_attachment" {
  target_group_arn = "${aws_alb_target_group.avni_alb_env_target_group.arn}"
  target_id = "${aws_instance.server.private_ip}"
}

resource "aws_security_group" "avni_alb_sg" {
  name = "Avni ALB Security Group"
  vpc_id = "${aws_vpc.avni_alb_vpc.id}"

  ingress {
    from_port = 443
    to_port   = 443
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

resource "aws_alb" "avni_alb" {
  name               = "avni-alb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    "${aws_subnet.avni_alb_subnetb.id}",
    "${aws_subnet.avni_alb_subnetb.id}",
  ]

  security_groups = [
    "${aws_security_group.avni_alb_sg.id}",
  ]
}

resource "aws_alb_listener" "avni_alb_listener_https" {
  load_balancer_arn = "${aws_alb.avni_alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${data.aws_acm_certificate.ssl_certificate.arn}"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      host = "avniproject.org"
      status_code="HTTP_301"
    }
  }
}

resource "aws_alb_listener" "avni_alb_listener_http" {
  load_balancer_arn = "${aws_alb.avni_alb.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol = "HTTPS"
      port = "443"
      status_code="HTTP_301"
    }
  }
}

resource "aws_alb_listener_rule" "avn_alb_listener_forward_to_env_target_group" {
  listener_arn = "${aws_alb_listener.avni_alb_listener_https.arn}"
  condition {
    host_header {
      values = ["hiren${lookup(var.url_map, var.environment, "temp")}.*"]
    }
  }

  action {
    target_group_arn = "${aws_alb_target_group.avni_alb_env_target_group.arn}"
    type = "forward"
  }
}
