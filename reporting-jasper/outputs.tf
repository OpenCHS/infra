output "reporting_jasper_server_ip" {
  value = "${aws_instance.reporting_jasper_server.*.public_ip}"
}

output "reporting_jasper_address" {
  value = "${aws_route53_record.reporting_jasper.name}"
}
