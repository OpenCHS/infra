resource "aws_kms_key" "db_encryption_key" {
  description             = "DB Encryption key"
}


resource "aws_db_instance" "openchs" {
  identifier = "proddb"
  allocated_storage = 100
  allow_major_version_upgrade = true
  apply_immediately = false
  auto_minor_version_upgrade = true
  backup_retention_period = 7
  storage_encrypted = true
  kms_key_id = "${aws_kms_key.db_encryption_key.arn}"
  publicly_accessible = false
  skip_final_snapshot = false
  final_snapshot_identifier = "prod-db-final-snapshot"
  storage_type = "gp2"
  db_subnet_group_name = "${aws_db_subnet_group.db_subnet.name}"
  engine = "postgres"
  engine_version = "9.6.11"
  instance_class = "db.t2.small"
  name = "openchs"
  username = "openchs"
  password = "password"
  vpc_security_group_ids = [
    "${aws_security_group.db_sg.id}"
  ]
  tags {
    Name = "prod OpenCHS Database"
    Environment = "prod"
  }
}