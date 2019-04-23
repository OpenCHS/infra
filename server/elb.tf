resource "aws_elb" "loadbalancer" {
  name = "${var.environment}-openchs-load-balancer"

  subnets = [
    "${aws_subnet.subneta.id}",
    "${aws_subnet.subnetb.id}"]

  security_groups = [
    "${aws_security_group.elb_sg.id}"]

  listener {
    instance_port = "${var.server_port}"
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${data.aws_acm_certificate.ssl_certificate.arn}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:${var.server_port}/ping"
    interval = 30
  }

  instances = [
    "${aws_instance.server.*.id}"
  ]
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {
    Name = "${var.environment}-openchs-server-load-balancer"
  }
}