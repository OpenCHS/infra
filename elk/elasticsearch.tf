resource "aws_security_group" "es_sg" {
  name = "es-sg"
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

  ingress {
    from_port = 9200
    to_port = 9200
    protocol = "tcp"
    cidr_blocks = [
      "${aws_vpc.elk_vpc.cidr_block}"
    ]
  }

  ingress {
    from_port = 9300
    to_port = 9300
    protocol = "tcp"
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
}

resource "aws_instance" "elasticsearch" {
  count = 1
  ami = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type = "${var.instance_type_es}"
  associate_public_ip_address = true
  vpc_security_group_ids = [
    "${aws_security_group.es_sg.id}"
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

  tags {
    Name = "Elastic Search"
  }
}

resource "null_resource" "update_elasticsearch" {
  count = "${aws_instance.elasticsearch.count}"
  triggers {
    script_checksum = "${md5(file("elk/provision/elasticsearch.sh"))}"
  }
  connection {
    host = "${element(aws_instance.elasticsearch.*.public_ip, count.index)}"
    user = "${var.default_ami_user}"
    private_key = "${file("elk/key/${var.key_name}.pem")}"
  }

  provisioner "file" {
    content = "${file("elk/provision/elasticsearch.sh")}"
    destination = "/tmp/elasticsearch.sh"
    connection {
      host = "${element(aws_instance.elasticsearch.*.public_ip, count.index)}"
      user = "${var.default_ami_user}"
      private_key = "${file("elk/key/${var.key_name}.pem")}"
    }
  }

  provisioner "file" {
    content = "${file("elk/provision/elasticsearch.yml")}"
    destination = "/tmp/elasticsearch.yml"
    connection {
      host = "${element(aws_instance.elasticsearch.*.public_ip, count.index)}"
      user = "${var.default_ami_user}"
      private_key = "${file("elk/key/${var.key_name}.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod a+x /tmp/elasticsearch.sh",
      "/tmp/elasticsearch.sh"
    ]
    connection {
      host = "${element(aws_instance.elasticsearch.*.public_ip, count.index)}"
      user = "${var.default_ami_user}"
      private_key = "${file("elk/key/${var.key_name}.pem")}"
    }
  }
  depends_on = ["aws_instance.elasticsearch"]
}
