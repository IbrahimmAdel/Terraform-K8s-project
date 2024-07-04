resource "aws_security_group" "bastion" {
  name        = "bastion-sg"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "k8s" {
  name        = "private-sg"
  description = "Allow SSH access from bastion server"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "jenkins" {
  name        = "jenkins-sg"
  description = "Allow HTTP access on port 8080 from LoadBalancer & SSH access from bastion server"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.jenkins_lb.id]
  }
  
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "bastion" {
  ami           	= "ami-04a81a99f5ec58529"
  instance_type 	= "t2.micro"
  subnet_id     	= aws_subnet.public.id
  key_name      	= aws_key_pair.bastion_key_pair.key_name
  security_groups 	= [aws_security_group.bastion.id]
  user_data = <<-EOF
    #!/bin/bash
    echo "${tls_private_key.jenkins_key.private_key_pem}" > /home/ubuntu/jenkins_private_key.pem
    chmod 400 /home/ubuntu/jenkins_private_key.pem
    sudo chown ubuntu:ubuntu /home/ubuntu/jenkins_private_key.pem
    echo "${tls_private_key.k8s_key.private_key_pem}" > /home/ubuntu/k8s_private_key.pem
    chmod 400 /home/ubuntu/k8s_private_key.pem
    sudo chown ubuntu:ubuntu /home/ubuntu/k8s_private_key.pem
  EOF
  
  tags = {
    Name = "bastion"
  }
}


resource "aws_instance" "k8s_cluster" {
  ami           	= "ami-04a81a99f5ec58529"
  instance_type 	= "t2.micro"
  subnet_id     	= aws_subnet.private.id
  key_name      	= aws_key_pair.k8s_key_pair.key_name
  security_groups 	= [aws_security_group.k8s.id]
  
  tags = {
    Name = "k8s-server"
  }
}


resource "aws_instance" "jenkins" {
  ami           	= "ami-04a81a99f5ec58529"
  instance_type 	= "t2.micro"
  subnet_id     	= aws_subnet.private.id
  key_name      	= aws_key_pair.jenkins_key_pair.key_name
  security_groups  	= [aws_security_group.jenkins.id]
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y openjdk-11-jdk
    sudo apt-get install -y wget gnupg
    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y jenkins
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
    sudo journalctl -u jenkins.service > /var/log/jenkins.log
  EOF
  
  tags = {
    Name = "jenkins-server"
  }
}
