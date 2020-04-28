data "template_file" "reporting_config" {
  template = "${file("reporting-jasper/provision/reporting-jasper.sh.tpl")}"

  vars {
    //    db_host     = "${aws_db_instance.reporting_jasper.address}"  //    db_port     = "${aws_db_instance.reporting_jasper.port}"  //    db_user     = "${aws_db_instance.reporting_jasper.username}"  //    db_name     = "${aws_db_instance.reporting_jasper.name}"  //    db_password = "${aws_db_instance.reporting_jasper.password}"  //    metabase_version = "${var.metabase_version}"
  }
}

resource "aws_instance" "reporting_jasper_server" {
  count                       = "${var.instance_count}"
  ami                         = "${var.ami}"
  availability_zone           = "${var.region}a"
  instance_type               = "${var.instance_type}"
  associate_public_ip_address = true

  vpc_security_group_ids = [
    "${aws_security_group.reporting_jasper_server_sg.id}",
  ]

  subnet_id            = "${aws_subnet.reportingjaspersubneta.id}"
  iam_instance_profile = "${aws_iam_instance_profile.reporting_jasper_instance.name}"
  key_name             = "${var.key_name}"

  root_block_device = {
    volume_size           = "${var.disk_size}"
    volume_type           = "gp2"
    delete_on_termination = false
  }

  tags {
    Name = "Reporting Jasper Instance"
  }
}

resource "null_resource" "update_instance" {
  count = "${aws_instance.reporting_jasper_server.count}"

  //  triggers {
  //    metabase_version = "${var.metabase_version}"
  //  }
  connection {
    host        = "${element(aws_instance.reporting_jasper_server.*.public_ip, count.index)}"
    user        = "${var.default_ami_user}"
    private_key = "${file("server/key/${var.key_name}.pem")}"
  }

  provisioner "file" {
    content     = "${data.template_file.reporting_config.rendered}"
    destination = "~/reporting-jasper.sh"

    connection {
      host        = "${element(aws_instance.reporting_jasper_server.*.public_ip, count.index)}"
      user        = "${var.default_ami_user}"
      private_key = "${file("server/key/${var.key_name}.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/reporting-jasper.sh",
      "~/reporting-jasper.sh 2>&1 > /dev/null",
    ]

    connection {
      host        = "${element(aws_instance.reporting_jasper_server.*.public_ip, count.index)}"
      user        = "${var.default_ami_user}"
      private_key = "${file("server/key/${var.key_name}.pem")}"
    }
  }
}

resource "aws_route53_record" "reporting_jasper" {
  zone_id = "${data.aws_route53_zone.openchs.zone_id}"
  name    = "reporting-jasper.${data.aws_route53_zone.openchs.name}"
  ttl     = 300
  type    = "A"

  records = [
    "${aws_instance.reporting_jasper_server.0.public_ip}",
  ]

  //  alias {
  //    evaluate_target_health = true
  //    name                   = "${aws_elb.reportingjasperloadbalancer.dns_name}"
  //    zone_id                = "${aws_elb.reportingjasperloadbalancer.zone_id}"
  //  }
}

resource "aws_route53_record" "reporting_jasper_server_instance" {
  zone_id = "${data.aws_route53_zone.openchs.zone_id}"
  name    = "ssh.reporting-jasper.${data.aws_route53_zone.openchs.name}"
  ttl     = 300
  type    = "A"

  records = [
    "${aws_instance.reporting_jasper_server.0.public_ip}",
  ]
}
