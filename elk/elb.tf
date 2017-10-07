resource "aws_security_group" "elb_sg" {
  name = "elk-elb-sg"
  description = "Allowed Ports on ELB"
  vpc_id = "${aws_vpc.elk_vpc.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "${aws_vpc.elk_vpc.cidr_block}"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  depends_on = [
    "aws_internet_gateway.elk_internet_gateway"
  ]
}

resource "aws_elb" "elk_loadbalancer" {
  name = "elk-openchs-load-balancer"

  subnets = [
    "${aws_subnet.elk_subneta.id}",
    "${aws_subnet.elk_subnetb.id}"]

  security_groups = [
    "${aws_security_group.elb_sg.id}"]

  listener {
    instance_port = "5601"
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:5601/status"
    interval = 30
  }

  instances = [
    "${aws_instance.kibana.*.id}"
  ]
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {
    Name = "elk-openchs-server-load-balancer"
  }
}

resource "aws_route53_record" "monitoring" {
  zone_id = "${data.aws_route53_zone.openchs.zone_id}"
  name = "monitoring.${data.aws_route53_zone.openchs.name}"
  type = "A"

  alias {
    evaluate_target_health = true
    name = "${aws_elb.elk_loadbalancer.dns_name}"
    zone_id = "${aws_elb.elk_loadbalancer.zone_id}"
  }
}
