output "alb_hostname" {
  value = aws_alb.main.dns_name
}

# output "private_ip" {
#   value = aws_instance.jenkins_cluster[0].private_ip
# }

# output "private_ip" {
#   value = module.ec2.private_ip[0]
# }