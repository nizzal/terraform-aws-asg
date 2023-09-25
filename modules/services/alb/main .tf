resource "aws_security_group" "WebServerALBSG" {
  name   = "webserver-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_alb" "WebServerALB" {
  name               = "web-server-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.WebServerALBSG.id]
  subnets            = [var.public_subnet_one, var.public_subnet_two]
  #depends_on         = [aws_s3_bucket.alb_log_bucket]

  access_logs {
    bucket  = var.alb_bucket_id
    enabled = true
  }
}

resource "aws_alb_target_group" "ALB-TG" {
  name     = "webserver-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/index.html"
    matcher             = "200-301"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_alb_listener" "webserver_alb_listener" {
  load_balancer_arn = aws_alb.WebServerALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ALB-TG.arn
  }
}

