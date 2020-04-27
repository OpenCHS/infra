resource "aws_iam_user" "reporting-jasper" {
  name = "reporting-jasper"
}

resource "aws_iam_access_key" "reporting_jasper_server_key" {
  user = "${aws_iam_user.reporting-jasper.name}"
}

resource "aws_iam_role" "reporting_jasper_role" {
  name               = "reporting_jasper_role"
  assume_role_policy = "${file("reporting-jasper/policy/server-role.json")}"
}

resource "aws_iam_role_policy" "reporting_jasper_instance_role_policy" {
  name   = "reporting_jasper_instance_role_policy"
  policy = "${file("reporting-jasper/policy/server-instance-role-policy.json")}"
  role   = "${aws_iam_role.reporting_jasper_role.id}"
}

resource "aws_iam_instance_profile" "reporting_jasper_instance" {
  name = "reporting_jasper_instance"
  path = "/"
  role = "${aws_iam_role.reporting_jasper_role.name}"
}

data "aws_acm_certificate" "ssl_certificate" {
  domain = "*.avniproject.org"

  statuses = [
    "ISSUED",
  ]
}
