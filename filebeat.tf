#security_group
resource "aws_security_group" "Fb-sg" {
  name        = "fb-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.stage-vpc.id

  ingress {
    description = "admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["45.249.77.103/32"]
  }
  ingress {
    description = "admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks = ["45.249.77.103/32"]
    security_groups = ["${aws_security_group.jenkins.id}"]
  }
  ingress {
    description     = "admin"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  ingress {
    description = "admin"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "admin"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "admin"
    from_port   = 5400
    to_port     = 5400
    protocol    = "tcp"
    /* security_groups = ["${aws_security_group.ek-sg.id}"] */
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "admin"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.siva-alb-sg.id}"]
    /* cidr_blocks = ["0.0.0.0/0"] */
  }
  ingress {
    description     = "admin"
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    security_groups = ["${aws_security_group.siva-alb-sg.id}"]
    /* cidr_blocks = ["0.0.0.0/0"] */
  }
  ingress {
    description     = "admin"
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    security_groups = ["${aws_security_group.grafana.id}"]
    /* cidr_blocks = ["0.0.0.0/0"] */
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "filebeat-sg"
  }
}
/* data "template_file" "filebeatuser" {
  template = file("fb-user-data.sh")

} */
#instance
resource "aws_instance" "Fb" {
  ami           = var.ami_ubuntu
  instance_type = var.type_ubuntu
  subnet_id     = aws_subnet.privatesubnet[0].id
  # availability_zone = data.aws_availability_zones.available.names[0]
  key_name               = aws_key_pair.deployer.id
  vpc_security_group_ids = [aws_security_group.Fb-sg.id]
  #user_data              = data.template_file.filebeatuser.rendered
   iam_instance_profile   = aws_iam_instance_profile.ssm_agent_instance_profile.name
  user_data = file("scripts/filebeat.sh")
  tags = {
    Name = "Filebeat"
  }
}



# alb target-group
resource "aws_lb_target_group" "siva-tg-filebeat" {
  name     = "filebeat-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.stage-vpc.id
}

resource "aws_lb_target_group_attachment" "siva-tg-attachment-filebeat" {
  target_group_arn = aws_lb_target_group.siva-tg-filebeat.arn
  target_id        = aws_instance.Fb.id
  port             = 8080
}



# alb-listner_rule
resource "aws_lb_listener_rule" "siva-filebeat-hostbased" {
  listener_arn = aws_lb_listener.siva-alb-listener.arn
  #   priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.siva-tg-filebeat.arn
  }

  condition {
    host_header {
      values = ["filebeat.siva.quest"]
    }
  }
}


/* 
# alb target-group
resource "aws_lb_target_group" "siva-tg-node" {
  name     = "node-tg"
  port     = 9100
  protocol = "HTTP"
  vpc_id   = aws_vpc.stage-vpc.id
}

resource "aws_lb_target_group_attachment" "siva-tg-attachment-node" {
  target_group_arn = aws_lb_target_group.siva-tg-node.arn
  target_id        = aws_instance.Fb.id
  port             = 9100
}



# alb-listner_rule
resource "aws_lb_listener_rule" "siva-node-hostbased" {
  listener_arn = aws_lb_listener.siva-alb-listener.arn
  #   priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.siva-tg-node.arn
  }

  condition {
    host_header {
      values = ["node.siva.quest"]
    }
  }
} */

