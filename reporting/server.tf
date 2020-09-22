data "template_file" "reporting_config" {
  template = "${file("reporting/provision/reporting.sh.tpl")}"

  vars {
    db_host = "${aws_db_instance.reporting.address}"
    db_port = "${aws_db_instance.reporting.port}"
    db_user = "${aws_db_instance.reporting.username}"
    db_name = "${aws_db_instance.reporting.name}"
    db_password = "${aws_db_instance.reporting.password}"
    metabase_version = "${var.metabase_version}"
  }
}

data "template_file" "reporting_log_config" {
  template = "${file("reporting/provision/log4j.properties.tpl")}"
}

resource "aws_instance" "reporting_server" {
  count = "${var.instance_count}"
  ami = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type = "${var.instance_type}"
  associate_public_ip_address = true
  vpc_security_group_ids = [
    "${aws_security_group.reporting_server_sg.id}"]
  subnet_id = "${aws_subnet.reportingsubneta.id}"
  iam_instance_profile = "${aws_iam_instance_profile.reporting_instance.name}"
  key_name = "${var.key_name}"
  root_block_device = {
    volume_size = "${var.disk_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  tags {
    Name = "Reporting Instance"
  }

}

resource "null_resource" "update_instance" {
  count = "${aws_instance.reporting_server.count}"
  triggers {
    metabase_version = "${var.metabase_version}"
  }
  connection {
    host = "${element(aws_instance.reporting_server.*.public_ip, count.index)}"
    user = "${var.default_ami_user}"
    private_key = "${file("reporting/key/${var.key_name}.pem")}"
  }

  provisioner "file" {
    content = "${data.template_file.reporting_config.rendered}"
    destination = "~/reporting.sh"
    connection {
      host = "${element(aws_instance.reporting_server.*.public_ip, count.index)}"
      user = "${var.default_ami_user}"
      private_key = "${file("reporting/key/${var.key_name}.pem")}"
    }
  }

  provisioner "file" {
    content = "${data.template_file.reporting_log_config.rendered}"
    destination = "~/log4j.properties"
    connection {
      host = "${element(aws_instance.reporting_server.*.public_ip, count.index)}"
      user = "${var.default_ami_user}"
      private_key = "${file("reporting/key/${var.key_name}.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/reporting.sh",
      "~/reporting.sh 2>&1 > /dev/null"
    ]
    connection {
      host = "${element(aws_instance.reporting_server.*.public_ip, count.index)}"
      user = "${var.default_ami_user}"
      private_key = "${file("reporting/key/${var.key_name}.pem")}"
    }
  }
}

resource "aws_route53_record" "reporting" {
  zone_id = "${data.aws_route53_zone.openchs.zone_id}"
  name = "reporting.${data.aws_route53_zone.openchs.name}"
  type = "A"

  alias {
    evaluate_target_health = true
    name = "${aws_elb.reportingloadbalancer.dns_name}"
    zone_id = "${aws_elb.reportingloadbalancer.zone_id}"
  }
}

resource "aws_route53_record" "reporting_server_instance" {
  zone_id = "${data.aws_route53_zone.openchs.zone_id}"
  name = "ssh.reporting.${data.aws_route53_zone.openchs.name}"
  ttl = 300
  type = "A"
  records = [
    "${aws_instance.reporting_server.0.public_ip}"
  ]
}

