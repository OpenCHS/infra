output "server_ip" {
  value = "${aws_instance.elasticsearch.*.public_ip}"
}

//output "address" {
//  value = "${aws_route53_record.server.name}"
//}
