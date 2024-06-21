
output "aws_ami" {
  value = data.aws_ami.get_latest_ubuntu22.id
}

output "jmeter_server_instances_id" {
  value = {
    for server in aws_instance.jmeter_server_instance :
    server.tags.Name => server.public_ip
  }
}
output "jmeter_client_instances_id" {
  value = "${aws_instance.jmeter_client_instance.tags.Name} = ${aws_instance.jmeter_client_instance.public_ip}"

}

output "jmeter_server_instances_ssh" {
  value = {
    for server in aws_instance.jmeter_server_instance :
    "${server.tags.Name} ssh conection string" => "ssh -i 'Test.pem' ubuntu@${server.public_dns}"
  }
}
output "jmeter_client_instances_ssh" {
  value = "${aws_instance.jmeter_client_instance.tags.Name} ssh conection string = ssh -i 'Test.pem' ubuntu@${aws_instance.jmeter_client_instance.public_dns}"
}
output "tls_private_key_value" {
  value     = tls_private_key.jmeter_instance_pem.private_key_pem
  sensitive = true
}


output "jmeter_report_link"{
  value = "http://${aws_instance.jmeter_client_instance.public_dns}:8080/index.html"
}