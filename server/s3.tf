resource "aws_s3_bucket" "server_bucket" {
  bucket = "${var.environment}-user-media"
  acl    = "private"

  tags = {
    Name        = "User media"
    Environment = "${var.environment}"
  }
}
