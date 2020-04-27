resource "aws_elb" "reportingjasperloadbalancer" {
  name = "reporting-load-balancer"

  subnets = [
    "${aws_subnet.reportingjaspersubneta.id}",
    "${aws_subnet.reportingjaspersubnetb.id}",
  ]

  security_groups = [
    "${aws_security_group.reporting_jasper_elb_sg.id}",
  ]

  listener {
    instance_port      = "8080"
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${data.aws_acm_certificate.ssl_certificate.arn}"
  }

  listener {
    instance_port     = "8080"
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/api/health"

    #TODO update health check target value
    interval = 30
  }

  instances = [
    "${aws_instance.reporting_jasper_server.*.id}",
  ]

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "reporting-jasper-load-balancer"
  }
}
