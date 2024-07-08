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
  user_data 		= file("userdata/bastion.sh")
  
  tags = {
    Name = "bastion-server"
  }
}


resource "aws_instance" "kubernetes" {
  ami           	= "ami-04a81a99f5ec58529"
  instance_type 	= "m5.xlarge"
  subnet_id     	= aws_subnet.private.id
  key_name      	= aws_key_pair.k8s_key_pair.key_name
  security_groups 	= [aws_security_group.k8s.id]
  user_data 		= file("userdata/kubernetes.sh")

  tags = {
    Name = "kubernetes-server"
  }
}


resource "aws_instance" "jenkins" {
  ami           	= "ami-04a81a99f5ec58529"
  instance_type 	= "t2.micro"
  subnet_id     	= aws_subnet.private.id
  key_name      	= aws_key_pair.jenkins_key_pair.key_name
  security_groups  	= [aws_security_group.jenkins.id]
  user_data 		= file("userdata/jenkins.sh.sh")
  
  tags = {
    Name = "jenkins-server"
  }
}
