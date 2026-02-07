output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.nginx_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.nginx_server.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.nginx_server.private_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.nginx_server.public_dns
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.nginx_sg.id
}
