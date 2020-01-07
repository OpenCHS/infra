resource "aws_iam_user" "server" {
  name = "${var.environment}_server"
}

resource "aws_iam_access_key" "server_key" {
  user = "${aws_iam_user.server.name}"
}

resource "aws_iam_role" "server_role" {
  name = "${var.environment}_server_role"
  assume_role_policy = "${file("server/policy/server-role.json")}"
}

resource "aws_iam_role_policy" "server_instance_role_policy" {
  name = "${var.environment}_server_instance_role_policy"
  policy = "${file("server/policy/server-instance-role-policy.json")}"
  role = "${aws_iam_role.server_role.id}"
}


resource "aws_iam_instance_profile" "server_instance" {
  name = "${var.environment}_server_instance"
  path = "/"
  role = "${aws_iam_role.server_role.name}"
}


data "aws_acm_certificate" "ssl_certificate" {
  domain   = "*.avniproject.org"
  statuses = ["ISSUED"]
}

resource "aws_iam_user" "server_app_iam_user" {
  name = "${var.environment}_app_iam_user"
}

data "template_file" "user_policy_file" {
  template = "${file("server/policy/server_app_iam_user_policy.json.tpl")}"

  vars {
    environment = "${var.environment}"
  }
}

resource "aws_iam_policy" "server_iam_policy" {
    name = "${var.environment}_iam_policy"
    policy = "${data.template_file.user_policy_file.rendered}"
}

resource "aws_iam_user_policy_attachment" "server_app_iam_user_policy_attachment" {
  user = "${aws_iam_user.server_app_iam_user.name}"
  policy_arn = "${aws_iam_policy.server_iam_policy.arn}"
}

resource "aws_iam_access_key" "server_app_iam_user_key" {
  user = "${aws_iam_user.server_app_iam_user.name}"
}
