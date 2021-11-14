output "load_balancer_ip" {
  value = aws_lb.loadbalancer.dns_name
}
