data "template_file" "config" {
  template = "${file("server/provision/openchs.conf.tpl")}"

  vars {
    database_host = "${aws_db_instance.openchs.address}"
    database_port = "${aws_db_instance.openchs.port}"
    database_user = "${aws_db_instance.openchs.username}"
    database_name = "${aws_db_instance.openchs.name}"
    server_port = "${var.server_port}"
    database_password = "${aws_db_instance.openchs.password}"
  }
}

data "template_file" "update" {
  template = "${file("server/provision/update.sh.tpl")}"

  vars {
    major_version = "0.0.1"
    minor_version = "64"
  }
}

resource "aws_instance" "server" {
  ami = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type = "${var.instance_type}"
  associate_public_ip_address = true
  vpc_security_group_ids = [
    "${aws_security_group.server_sg.id}"]
  subnet_id = "${aws_subnet.subneta.id}"
  iam_instance_profile = "${aws_iam_instance_profile.server_instance.name}"
  key_name = "${aws_key_pair.openchs.key_name}"
  root_block_device = {
    volume_size = "${var.disk_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  provisioner "remote-exec" {
    inline = [
      "curl -L https://bintray.com/openchs/rpm/rpm > /tmp/bintray-openchs-rpm.repo",
      "sudo mv /tmp/bintray-openchs-rpm.repo /etc/yum.repos.d/bintray-openchs-rpm.repo",
      "sudo yum -y install openchs-server"
    ]
    connection {
      user = "${var.default_ami_user}"
      private_key = "${file("server/key/${aws_key_pair.openchs.key_name}.pem")}"
    }
  }

  provisioner "file" {
    content = "${data.template_file.config.rendered}"
    destination = "/tmp/openchs.conf"
    connection {
      user = "${var.default_ami_user}"
      private_key = "${file("server/key/${aws_key_pair.openchs.key_name}.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/openchs.conf /etc/openchs/openchs.conf"
    ]
    connection {
      user = "${var.default_ami_user}"
      private_key = "${file("server/key/${aws_key_pair.openchs.key_name}.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo service openchs start"
    ]
    connection {
      user = "${var.default_ami_user}"
      private_key = "${file("server/key/${aws_key_pair.openchs.key_name}.pem")}"
    }
  }
}

resource "null_resource" "update_instance" {
  connection {
    type = "ssh"
    user = "${var.default_ami_user}"
    private_key = "${file("server/key/${aws_key_pair.openchs.key_name}.pem")}"
  }

  provisioner "file" {
    content = "${data.template_file.update.rendered}"
    destination = "/tmp/update.sh"
    connection {
      user = "${var.default_ami_user}"
      private_key = "${file("server/key/${aws_key_pair.openchs.key_name}.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/update.sh",
      "/tmp/update.sh"
    ]
    
    connection {
      host = "${aws_instance.server.public_ip}"
      user = "${var.default_ami_user}"
      private_key = "${file("server/key/${aws_key_pair.openchs.key_name}.pem")}"
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
