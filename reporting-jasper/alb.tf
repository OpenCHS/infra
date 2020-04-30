resource "aws_lb" "reportingjasperloadbalancer" {
  name               = "reporting-jasper-load-balancer"
  internal           = false
  load_balancer_type = "application"
  idle_timeout       = 400

  subnets = [
    "${aws_subnet.reportingjaspersubneta.id}",
    "${aws_subnet.reportingjaspersubnetb.id}",
  ]

  security_groups = [
    "${aws_security_group.reporting_jasper_alb_sg.id}",
  ]

  tags {
    Name = "reporting-jasper-load-balancer"
  }
}

resource "aws_lb_listener" "reportingjasperloadbalancerlistenerhttp" {
  load_balancer_arn = "${aws_lb.reportingjasperloadbalancer.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.reportingjasperloadbalancertargetgroup.arn}"
  }
}

resource "aws_lb_listener" "reportingjasperloadbalancerlistenerhttps" {
  load_balancer_arn = "${aws_lb.reportingjasperloadbalancer.arn}"
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = "${data.aws_acm_certificate.ssl_certificate.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.reportingjasperloadbalancertargetgroup.arn}"
  }
}

resource "aws_lb_target_group" "reportingjasperloadbalancertargetgroup" {
  name                 = "reporting-jasper-loadbalancer-tg"
  port                 = "8080"
  protocol             = "HTTP"
  target_type          = "instance"
  deregistration_delay = 400
  vpc_id               = "${aws_vpc.reportingjaspervpc.id}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path                = "/jasperserver/login.html"
    port                = "8080"
    interval            = 30
    matcher             = "200-299"
  }

  tags {
    Name = "reporting-jasper-load-balancer Target group"
  }
}

resource "aws_lb_target_group_attachment" "reportingjasperloadbalancertargetgroupinstances" {
  target_group_arn = "${aws_lb_target_group.reportingjasperloadbalancertargetgroup.arn}"
  target_id        = "${element(aws_instance.reporting_jasper_server.*.id, count.index)}"
}
