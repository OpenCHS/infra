resource "aws_elb" "reportingloadbalancer" {
  name = "reporting-load-balancer"

  subnets = [
    "${aws_subnet.reportingsubneta.id}",
    "${aws_subnet.reportingsubnetb.id}"]

  security_groups = [
    "${aws_security_group.reporting_elb_sg.id}"]

  listener {
    instance_port = "3000"
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${data.aws_acm_certificate.ssl_certificate.arn}"
  }

  listener {
    instance_port = "3000"
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:3000/api/health"
    interval = 30
  }

  instances = [
    "${aws_instance.reporting_server.*.id}"]
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {
    Name = "reporting-load-balancer"
  }
}