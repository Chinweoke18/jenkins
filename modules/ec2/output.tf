output "instance" {
  value = aws_instance.jenkins_cluster
}

output "instance_private_IP" {
  value = aws_instance.jenkins_cluster[0].private_ip
}

