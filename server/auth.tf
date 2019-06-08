resource "aws_iam_role" "sms_role" {
  name = "${var.environment}_sms_role"
  assume_role_policy = "${file("server/policy/sms-role.json")}"
}

resource "aws_iam_role_policy" "sms_role_policy" {
  name = "${var.environment}_sms_role_policy"
  policy = "${file("server/policy/sms-role-policy.json")}"
  role = "${aws_iam_role.sms_role.id}"
}

resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.environment}-openchs"
  auto_verified_attributes = [
    "phone_number"]
  sms_configuration {
    external_id = "67c8df07-a2ad-4849-8ef9-8313aef3c52c"
    sns_caller_arn = "${aws_iam_role.sms_role.arn}"
  }
  admin_create_user_config {
    allow_admin_create_user_only = true
    unused_account_validity_days = 90
  }
  device_configuration {
    device_only_remembered_on_user_prompt = false
    challenge_required_on_new_device = true
  }
  password_policy {
    minimum_length = 8
    require_lowercase = true
    require_numbers = false
    require_symbols = false
    require_uppercase = false
  }
  schema {
    attribute_data_type = "String"
    mutable = true
    name = "organisationId"
  }
  schema {
    attribute_data_type = "String"
    mutable = true
    name = "organisationName"
  }
  schema {
    attribute_data_type = "String"
    mutable = true
    name = "catchmentId"
  }
  schema {
    attribute_data_type = "String"
    mutable = true
    name = "isUser"
  }
  schema {
    attribute_data_type = "String"
    mutable = true
    name = "isAdmin"
  }
  schema {
    attribute_data_type = "String"
    mutable = true
    name = "email"
    required = true
  }
  schema {
    attribute_data_type = "String"
    mutable = true
    name = "isOrganisationAdmin"
  }
  schema {
    attribute_data_type = "String"
    mutable = true
    name = "userUUID"
  }

  tags {
    Name = "${var.environment}-auth-service"
    Environment = "${var.environment}"
  }
}

resource "null_resource" "client_id" {

  triggers {
    user_pool_id = "${aws_cognito_user_pool.user_pool.id}"
  }

  provisioner "local-exec" {
    command = "python ${path.module}/provision/user_pool_client.py ${aws_cognito_user_pool.user_pool.id} > server/version/client_id"
  }
  depends_on = [
    "aws_cognito_user_pool.user_pool"
  ]
}