output "server_endpoint" {
  value       = module.alb_server.dns_alb
  description = "Copy this value in your browser to access service"
}