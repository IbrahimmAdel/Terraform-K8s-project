resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "bastion_key_pair" {
  key_name   = "main-key"
  public_key = tls_private_key.bastion_key.public_key_openssh
}


# Download and save bastion private key
resource "local_file" "bastion_private_key" {
  content  = tls_private_key.bastion_key.private_key_pem
  filename = "./bastion_private_key.pem"
}


resource "null_resource" "set_permissions" {
  provisioner "local-exec" {
    command = "chmod 400 ./bastion_private_key.pem"
  }
  
  depends_on = [local_file.bastion_private_key]
}


resource "tls_private_key" "jenkins_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "jenkins_key_pair" {
  key_name   = "jenkins-key"
  public_key = tls_private_key.jenkins_key.public_key_openssh
}


resource "tls_private_key" "k8s_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "k8s_key_pair" {
  key_name   = "k8s-key"
  public_key = tls_private_key.k8s_key.public_key_openssh
}
