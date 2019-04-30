data "template_file" "web_app" {
  template = "${file("webapp/provision/webapp.sh.tpl")}"
  vars {
    build_version = "${trimspace(file("webapp/version/build_version"))}"
  }
}


resource "null_resource" "copy_content" {

  triggers {
    build_version = "${trimspace(file("webapp/version/build_version"))}"
  }
  
  provisioner "file" {
    content = "${data.template_file.web_app.rendered}"
    destination = "/tmp/webapp.sh"
    connection {
      host = "ssh.${lookup(var.url_map, var.environment, "temp")}.${var.server_name}"
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
      host = "ssh.${lookup(var.url_map, var.environment, "temp")}.${var.server_name}"
      user = "${var.default_ami_user}"
      private_key = "${file("webapp/key/${var.key_name}.pem")}"
    }
  }

}
