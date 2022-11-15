resource "aws_instance" "elb_instance_jumpserver" {
  ami           = "ami-09d3b3274b6c5d4aa"
  instance_type = var.instance_type
  subnet_id     = "subnet-007ad6cef227b3e61"
  vpc_security_group_ids = [aws_security_group.elb.id]
  key_name = "Anand_key"
  tags = {
    Name = "EC2-jumpserver-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "elb_instance_example1" {
  ami           = "ami-09d3b3274b6c5d4aa"
  instance_type = var.instance_type
  subnet_id     = "subnet-0d586573f91168a95"
  # Security group assign to instance
  vpc_security_group_ids = [aws_security_group.elb.id]
  # key name
  key_name = "Anand_key"

  user_data = <<EOF
                #! /bin/bash
                sudo yum update -y
                sudo yum install -y httpd.x86_64
                sudo service httpd start
                sudo service httpd enable
                echo "<h1>Deployed ELB Instance Example 1</h1>" | sudo tee /var/www/html/index.html
        EOF

  tags = {
    Name = "EC2-private-Instance-1"
  }
}




resource "aws_lb" "elb_anand1" {
  name               = "elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_ssh.id]
  subnets            = ["subnet-007ad6cef227b3e61", "subnet-0c77f24327971d789"]

  enable_deletion_protection = false
  tags = {
    Environment = "elb-anand1"
  }
}

#resource "aws_lb_listener" "front_end" {
# load_balancer_arn = aws_lb.elb_anand1.arn
# port              = "80"
# protocol          = "HTTP"

# default_action {
#   type             = "forward"
#   target_group_arn = aws_lb_target_group.test.arn

# }
#}



resource "aws_alb_target_group" "test" {
  name     = "test-loadbalancer"
  vpc_id   = "vpc-07eaa04b9a277de9a"
  port     = "443"
  protocol = "HTTPS"
  health_check {
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 5
    timeout             = 4
    matcher             = "200-308"
  }
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_alb_target_group.test.arn
  target_id        = aws_instance.elb_instance_example1.id
  port             = 80
}

resource "aws_alb_listener" "alb_front_https" {
  load_balancer_arn = aws_lb.elb_anand1.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:602011150591:certificate/a9975f03-c447-4d90-a37d-6d7ea58a809b"

  default_action {
    target_group_arn = aws_alb_target_group.test.arn
    type             = "forward"
  }
}

#output "elb_example" {
#  description = "The DNS name of the ELB"
#  value       = aws_lb.elb_anand1.dns_name
#}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_SSH"
  description = "Allow SSH inbound traffic"
  vpc_id      = "vpc-07eaa04b9a277de9a"

  ingress {
    # SSH Port 22 allowed from any IP
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # SSH Port 80 allowed from any IP
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # SSH Port 80 allowed from any IP
    from_port   = 443
    to_port     = 443
    protocol    = "https"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb" {
  name   = "terraform-example-elb"
  vpc_id = "vpc-07eaa04b9a277de9a"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_route53_record" "www" {
  zone_id = "Z0047012345SPV29LHM87"
  name    = "karthik.cloudzenix.online"
  type    = "A"

  alias {
    name                   = aws_lb.elb_anand1.dns_name
    zone_id                = aws_lb.elb_anand1.zone_id
    evaluate_target_health = true
  }
}

# resource "aws_route53_record" "zone-1" {
#  zone_id = "Z0047012345SPV29LHM87"
#  name    = "anand.cloudzenix.online"
#  type    = "A"
#  ttl     = "60"
#  records = [aws_lb.elb_anand1.dns_name]
#  alias {
#     name                   = aws_lb.elb_anand1.dns_name
#     zone_id                = "Z0047012345SPV29LHM87"
#      evaluate_target_health = true
#    }
#}
# output "name_server" {
# value = aws_route53_zone.zone.name_servers
#}

