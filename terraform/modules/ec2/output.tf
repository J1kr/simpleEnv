output "instance_id" {
  description = "EC2 instance ID"
  value       = "${aws_instance.ec2.id}"
}

output "internel_sg" {
  description = "internel Network"
  value       = "${aws_security_group.Internel.id}"
}

