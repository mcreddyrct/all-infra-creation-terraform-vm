#apache-security group
resource "aws_security_group" "nexus" {
  name        = "nexus"
  description = "this is using for securitygroup"
  vpc_id      = aws_vpc.stage-vpc.id

  ingress {
    description = "this is inbound rule"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["45.249.77.103/32"]
  }
  ingress {
    description     = "this is inbound rule"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }
  ingress {
    description = "this is inbound rule"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description     = "this is inbound rule"
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    security_groups = ["${aws_security_group.siva-alb-sg.id}"]
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
    Name = "nexus"
  }
}
#apacheuserdata
/* data "template_file" "nexususer" {
  template = file("nexus.sh")

} */
# apache instance
resource "aws_instance" "nexus" {
  ami                    = var.ami
  instance_type          = var.type_small
  subnet_id              = aws_subnet.privatesubnet[0].id
  vpc_security_group_ids = [aws_security_group.nexus.id]
   key_name               = aws_key_pair.deployer.id
  #user_data              = data.template_file.nexususer.rendered
   iam_instance_profile   = aws_iam_instance_profile.ssm_agent_instance_profile.name
  user_data = file("scripts/nexus.sh")
  tags = {
    Name = "stage-nexus"
  }
}

# alb target-group
resource "aws_lb_target_group" "siva-tg-nexus" {
  name     = "tg-nexus"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = aws_vpc.stage-vpc.id
}

resource "aws_lb_target_group_attachment" "siva-tg-attachment-nexus" {
  target_group_arn = aws_lb_target_group.siva-tg-nexus.arn
  target_id        = aws_instance.nexus.id
  port             = 8081
}



# alb-listner_rule
resource "aws_lb_listener_rule" "siva-nexus-hostbased" {
  listener_arn = aws_lb_listener.siva-alb-listener.arn
  #   priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.siva-tg-nexus.arn
  }

  condition {
    host_header {
      values = ["nexus.siva.quest"]
    }
  }
}

