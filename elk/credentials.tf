resource "aws_key_pair" "openchs" {
  key_name = "${var.key_name}"
  public_key = "${file("elk/key/${var.key_name}.pub")}"
}

resource "aws_iam_user" "elk" {
  name = "logstash"
}

resource "aws_iam_access_key" "elk_key" {
  user = "${aws_iam_user.elk.name}"
}

resource "aws_iam_role" "elk_role" {
  name = "elk_role"
  assume_role_policy = "${file("elk/policy/server-role.json")}"
}

resource "aws_iam_role_policy" "elk_instance_role_policy" {
  name = "elk_instance_role_policy"
  policy = "${file("elk/policy/server-instance-role-policy.json")}"
  role = "${aws_iam_role.elk_role.id}"
}


resource "aws_iam_instance_profile" "elk_instance" {
  name = "elk_instance"
  path = "/"
  role = "${aws_iam_role.elk_role.name}"
}

