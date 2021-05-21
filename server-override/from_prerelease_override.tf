data "aws_db_snapshot" "latest_snapshot" {
  db_instance_identifier = "proddb02"
  most_recent = true
}

resource "aws_db_instance" "openchs" {
  allocated_storage = 100
  instance_class = "db.t2.small"
  storage_encrypted = true
  snapshot_identifier = "${data.aws_db_snapshot.latest_snapshot.db_snapshot_identifier}"
}
