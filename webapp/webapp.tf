data "template_file" "web_app" {
  template = "${file("webapp/provision/webapp.sh.tpl")}"
  vars {
    build_version = "${var.circle_build_num}"
  }
}


resource "null_resource" "copy_content" {

  provisioner "file" {
    content = "${data.template_file.web_app.rendered}"
    destination = "/tmp/webapp.sh"
    connection {
      host = "ssh.staging.openchs.org"
      user = "${var.default_ami_user}"
      private_key = "${file("webapp/key/${var.key_name}.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/webapp.sh",
      "/tmp/webapp.sh"
    ]

    connection {
      host = "ssh.staging.openchs.org"
      user = "${var.default_ami_user}"
      private_key = "${file("webapp/key/${var.key_name}.pem")}"
    }
  }

}

/*resource "aws_route53_record" "webapp" {
  zone_id = "${data.aws_route53_zone.openchs.zone_id}"
  name = "app.${data.aws_route53_zone.openchs.name}" //hardcoded
  type = "A"

  alias {
    evaluate_target_health = true
    name = "${aws_elb.loadbalancer.dns_name}"
    zone_id = "${aws_elb.loadbalancer.zone_id}"
  }
}*/
