resource "aws_security_group" "logstash_sg" {
  name = "logstash-sg"
  description = "Allowed Ports"
  vpc_id = "${aws_vpc.elk_vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
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
}

data "template_file" "logstash_conf" {
  template = "${file("elk/provision/logstash.conf.tpl")}"

  vars {
    elasticsearch_host = "${aws_instance.elasticsearch.private_ip}:9200"
  }
}


resource "aws_instance" "logstash" {
  count = 1
  ami = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type = "${var.instance_type}"
  associate_public_ip_address = true
  vpc_security_group_ids = [
    "${aws_security_group.logstash_sg.id}"
  ]
  subnet_id = "${aws_subnet.elk_subneta.id}"
  iam_instance_profile = "${aws_iam_instance_profile.elk_instance.name}"
  key_name = "${var.key_name}"
  root_block_device = {
    volume_size = "${var.disk_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  provisioner "file" {
    content = "${file("elk/provision/elastic.repo")}"
    destination = "/tmp/elastic.repo"
    connection {
      user = "${var.default_ami_user}"
      private_key = "${file("elk/key/${var.key_name}.pem")}"
    }
  }

  provisioner "file" {
    content = "${file("elk/provision/base.sh")}"
    destination = "/tmp/base.sh"
    connection {
      user = "${var.default_ami_user}"
      private_key = "${file("elk/key/${var.key_name}.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/elastic.repo /etc/yum.repos.d/elastic.repo",
      "sudo chmod a+x /tmp/base.sh",
      "/tmp/base.sh"
    ]
    connection {
      user = "${var.default_ami_user}"
      private_key = "${file("elk/key/${var.key_name}.pem")}"
    }
  }

  depends_on = [
    "null_resource.update_elasticsearch"
  ]

  tags {
    Name = "Logstash"
  }
}

resource "null_resource" "update_logstash" {
  count = "${aws_instance.logstash.count}"
  triggers {
    elasticsearch_ip = "${aws_instance.elasticsearch.0.private_ip}"
    script_checksum = "${md5(file("elk/provision/logstash.sh"))}"
  }
  connection {
    host = "${element(aws_instance.logstash.*.public_ip, count.index)}"
    user = "${var.default_ami_user}"
    private_key = "${file("elk/key/${var.key_name}.pem")}"
  }

  provisioner "file" {
    content = "${file("elk/provision/logstash.sh")}"
    destination = "/tmp/logstash.sh"
    connection {
      host = "${element(aws_instance.logstash.*.public_ip, count.index)}"
      user = "${var.default_ami_user}"
      private_key = "${file("elk/key/${var.key_name}.pem")}"
    }
  }

  provisioner "file" {
    content = "${data.template_file.logstash_conf.rendered}"
    destination = "/tmp/logstash.conf"
    connection {
      host = "${element(aws_instance.logstash.*.public_ip, count.index)}"
      user = "${var.default_ami_user}"
      private_key = "${file("elk/key/${var.key_name}.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/logstash.conf /etc/logstash/conf.d/logstash.conf",
      "sudo chmod a+rx /etc/logstash/conf.d/logstash.conf",
      "sudo chmod a+x /tmp/logstash.sh",
      "/tmp/logstash.sh"
    ]
    connection {
      host = "${element(aws_instance.logstash.*.public_ip, count.index)}"
      user = "${var.default_ami_user}"
      private_key = "${file("elk/key/${var.key_name}.pem")}"
    }
  }
  depends_on = ["aws_instance.logstash"]
}
