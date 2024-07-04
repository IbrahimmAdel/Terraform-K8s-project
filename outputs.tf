output "k8s_bastion_public_ip" {
  value = aws_instance.k8s_bastion.public_ip
}


output "k8s_private_ip" {
  value = aws_instance.k8s_cluster.private_ip
}


output "jenkins_bastion_public_ip" {
  value = aws_instance.bastion_jenkins.public_ip
}


output "jenkins_server_private_ip" {
  value = aws_instance.jenkins.private_ip
}


output "load_balancer_dns" {
  value = aws_lb.jenkins_lb.dns_name
}
