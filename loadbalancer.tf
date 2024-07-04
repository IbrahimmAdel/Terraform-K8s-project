resource "aws_security_group" "jenkins_lb" {
  name        = "jenkins-lb-sg"
  description = "Allow HTTP/HTTPS from anywhere for Jenkins load balancer"
  vpc_id      = aws_vpc.main.id
  
    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
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


resource "aws_lb" "jenkins_lb" {
  name               		= "jenkins-lb"
  internal           		= false
  load_balancer_type 		= "application"
  security_groups    		= [aws_security_group.jenkins_lb.id]
  subnets            		= [aws_subnet.public.id, aws_subnet.private.id]
  enable_deletion_protection 	= false
  
  tags = {
    Name = "jenkins-lb"
  }
}


resource "aws_lb_target_group" "jenkins_tg" {
  name     	= "jenkins-tg"
  port     	= 8080
  protocol 	= "HTTP"
  vpc_id   	= aws_vpc.main.id
  target_type 	= "instance"
  health_check {
    path                = "/login"
    port                = 8080
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  
  tags = {
    Name = "jenkins-tg"
  }
}


resource "aws_lb_listener" "jenkins_listener" {
  load_balancer_arn = aws_lb.jenkins_lb.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  
  }
}


resource "aws_lb_target_group_attachment" "jenkins_attachment_1" {
  target_group_arn = aws_lb_target_group.jenkins_tg.arn
  target_id        = aws_instance.jenkins.id
  port             = 8080
}
