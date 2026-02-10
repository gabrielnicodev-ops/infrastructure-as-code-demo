output "instance_ip" {
  description = "IP Publica del servidor nuevo"
  value       = aws_instance.app_server.public_ip
}