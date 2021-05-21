resource "aws_db_subnet_group" "db_subnet" {
  name = "${var.environment}_main"
  subnet_ids = [
    "${aws_subnet.subneta.id}",
    "${aws_subnet.subnetb.id}"]

  tags {
    Name = "${var.environment} DB subnet group"
  }
}

resource "aws_db_instance" "openchs" {
  identifier = "${var.environment}db"
  allocated_storage = 5
  allow_major_version_upgrade = true
  apply_immediately = false
  auto_minor_version_upgrade = true
  backup_retention_period = 7
  storage_encrypted = false
  publicly_accessible = false
  skip_final_snapshot = "${lookup(var.db_final_snapshot, var.environment, true)}"
  final_snapshot_identifier = "${var.environment}-db-final-snapshot"
  storage_type = "${lookup(var.db_ssd_type, var.environment, "gp2")}"
  db_subnet_group_name = "${aws_db_subnet_group.db_subnet.name}"
  engine = "postgres"
  engine_version = "12.5"
  instance_class = "db.t2.micro"
  name = "openchs"
  username = "openchs"
  password = "password"
  vpc_security_group_ids = [
    "${aws_security_group.db_sg.id}"
  ]
  tags {
    Name = "${var.environment} OpenCHS Database"
    Environment = "${var.environment}"
  }
}


resource "aws_route53_record" "database" {
  zone_id = "${data.aws_route53_zone.openchs.zone_id}"
  name = "${lookup(var.url_map, var.environment, "temp")}db"
  type = "CNAME"
  ttl = 300
  records = [
    "${aws_db_instance.openchs.address}"
  ]
}
