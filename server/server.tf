data "template_file" "config" {
  template = "${file("server/provision/openchs.conf.tpl")}"

  vars {
    database_host = "${aws_route53_record.database.name}.${data.aws_route53_zone.openchs.name}"
    database_port = "${aws_db_instance.openchs.port}"
    database_user = "${aws_db_instance.openchs.username}"
    database_name = "${aws_db_instance.openchs.name}"
    server_port = "${var.server_port}"
    database_password = "${aws_db_instance.openchs.password}"
    client_id = "${file("server/version/client_id")}"
    user_pool_id = "${aws_cognito_user_pool.user_pool.id}"
    bugsnag_api_key = "${var.bugsnag_api_key}"
    environment = "${var.environment}"
    server_iam_user = "${aws_iam_user.server_app_iam_user.name}"
    iam_access_key = "${aws_iam_access_key.server_app_iam_user_key.id}"
    iam_secret_access_key = "${aws_iam_access_key.server_app_iam_user_key.secret}"
    bucket_name="${var.environment}-user-media"
  }

  depends_on = [
    "null_resource.client_id",
    "aws_cognito_user_pool.user_pool"]
}

data "template_file" "update" {
  template = "${file("server/provision/update.sh.tpl")}"

  vars {
    major_version = "${file("server/version/major_version")}"
    minor_version = "${file("server/version/minor_version")}"
  }
}

resource "aws_instance" "server" {
  count = 1
  ami = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type = "${lookup(var.instance_map, var.environment, var.instance_type)}"
  associate_public_ip_address = true
  vpc_security_group_ids = [
    "${aws_security_group.server_sg.id}"]
  subnet_id = "${aws_subnet.subneta.id}"
  iam_instance_profile = "${aws_iam_instance_profile.server_instance.name}"
  key_name = "${var.key_name}"
  disable_api_termination = "${lookup(var.disable_api_termination, var.environment, false)}"
  root_block_device = {
    volume_size = "${var.disk_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  provisioner "remote-exec" {
    inline = [
      "curl -L https://bintray.com/openchs/rpm/rpm > /tmp/bintray-openchs-rpm.repo",
      "sudo mv /tmp/bintray-openchs-rpm.repo /etc/yum.repos.d/bintray-openchs-rpm.repo"
    ]
    connection {
      user = "${var.default_ami_user}"
      private_key = "${file("server/key/${var.key_name}.pem")}"
    }
  }

  provisioner "file" {
    content = "${data.template_file.config.rendered}"
    destination = "/tmp/openchs.conf"
    connection {
      user = "${var.default_ami_user}"
      private_key = "${file("server/key/${var.key_name}.pem")}"
    }
  }

  tags {
    Name = "${var.environment} Machine"
  }
}

resource "null_resource" "update_instance" {

  triggers {
    major_version = "${file("server/version/major_version")}"
    minor_version = "${file("server/version/minor_version")}"
  }
  count = "${aws_instance.server.count}"

  connection {
    host = "${element(aws_instance.server.*.public_ip, count.index)}"
    user = "${var.default_ami_user}"
    private_key = "${file("server/key/${var.key_name}.pem")}"
  }

  provisioner "file" {
    content = "${data.template_file.config.rendered}"
    destination = "/tmp/openchs.conf"
    connection {
      user = "${var.default_ami_user}"
      private_key = "${file("server/key/${var.key_name}.pem")}"
    }
  }

  provisioner "file" {
    content = "${data.template_file.update.rendered}"
    destination = "/tmp/update.sh"
    connection {
      host = "${element(aws_instance.server.*.public_ip, count.index)}"
      user = "${var.default_ami_user}"
      private_key = "${file("server/key/${var.key_name}.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/update.sh",
      "/tmp/update.sh"
    ]

    connection {
      host = "${element(aws_instance.server.*.public_ip, count.index)}"
      user = "${var.default_ami_user}"
      private_key = "${file("server/key/${var.key_name}.pem")}"
    }
  }
}

resource "aws_route53_record" "server" {
  zone_id = "${data.aws_route53_zone.openchs.zone_id}"
  name = "${lookup(var.url_map, var.environment, "temp")}.${data.aws_route53_zone.openchs.name}"
  type = "A"

  alias {
    evaluate_target_health = true
    name = "${aws_elb.loadbalancer.dns_name}"
    zone_id = "${aws_elb.loadbalancer.zone_id}"
  }
}

resource "aws_route53_record" "server_instance" {
  zone_id = "${data.aws_route53_zone.openchs.zone_id}"
  name = "ssh.${lookup(var.url_map, var.environment, "temp")}.${data.aws_route53_zone.openchs.name}"
  type = "A"
  ttl = 300
  records = [
    "${aws_instance.server.0.public_ip}"
  ]
}
