resource "aws_security_group" "kibana_sg" {
  name = "kibana-sg"
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
    from_port = 5601
    to_port = 5601
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

data "template_file" "kibana_conf" {
  template = "${file("elk/provision/kibana.yml.tpl")}"

  vars {
    elasticsearch_host = "http://${aws_instance.elasticsearch.private_ip}:9200"
  }
}


resource "aws_instance" "kibana" {
  count = 1
  ami = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type = "${var.instance_type}"
  associate_public_ip_address = true
  vpc_security_group_ids = [
    "${aws_security_group.kibana_sg.id}"
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
    Name = "Kibana"
  }
}

resource "null_resource" "update_kibana" {
  count = "${aws_instance.kibana.count}"

  triggers {
    elasticsearch_ip = "${aws_instance.elasticsearch.0.private_ip}"
    script_checksum = "${md5(file("elk/provision/kibana.sh"))}"
  }
  
  connection {
    host = "${element(aws_instance.kibana.*.public_ip, count.index)}"
    user = "${var.default_ami_user}"
    private_key = "${file("elk/key/${var.key_name}.pem")}"
  }


  provisioner "file" {
    content = "${file("elk/provision/kibana.sh")}"
    destination = "/tmp/kibana.sh"
    connection {
      host = "${element(aws_instance.kibana.*.public_ip, count.index)}"
      user = "${var.default_ami_user}"
      private_key = "${file("elk/key/${var.key_name}.pem")}"
    }
  }

  provisioner "file" {
    content = "${data.template_file.kibana_conf.rendered}"
    destination = "/tmp/kibana.yml"
    connection {
      host = "${element(aws_instance.kibana.*.public_ip, count.index)}"
      user = "${var.default_ami_user}"
      private_key = "${file("elk/key/${var.key_name}.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/kibana.yml /etc/kibana/kibana.yml",
      "sudo chmod a+rx /etc/kibana/kibana.yml",
      "sudo chmod a+x /tmp/kibana.sh",
      "/tmp/kibana.sh"
    ]
    connection {
      host = "${element(aws_instance.kibana.*.public_ip, count.index)}"
      user = "${var.default_ami_user}"
      private_key = "${file("elk/key/${var.key_name}.pem")}"
    }
  }
  depends_on = ["aws_instance.kibana"]
}

