resource "aws_iam_user" "reporting" {
  name = "reporting"
}

resource "aws_iam_access_key" "reporting_server_key" {
  user = "${aws_iam_user.reporting.name}"
}

resource "aws_iam_role" "reporting_role" {
  name = "reporting_role"
  assume_role_policy = "${file("reporting/policy/server-role.json")}"
}

resource "aws_iam_role_policy" "reporting_instance_role_policy" {
  name = "reporting_instance_role_policy"
  policy = "${file("reporting/policy/server-instance-role-policy.json")}"
  role = "${aws_iam_role.reporting_role.id}"
}


resource "aws_iam_instance_profile" "reporting_instance" {
  name = "reporting_instance"
  path = "/"
  role = "${aws_iam_role.reporting_role.name}"
}

data "aws_acm_certificate" "ssl_certificate" {
  domain   = "*.avniproject.org"
  statuses = ["ISSUED"]
}