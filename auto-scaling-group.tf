resource "aws_security_group" "WebServerALBSG" {
  name   = "webserver-alb-sg"
  vpc_id = aws_vpc.MainVPC.id

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
  subnets            = [aws_subnet.PublicSubnetOne.id, aws_subnet.PublicSubnetTwo.id]
  depends_on         = [aws_s3_bucket.alb_log_bucket]

  access_logs {
    bucket  = aws_s3_bucket.alb_log_bucket.id
    enabled = true
  }
}

resource "aws_alb_target_group" "ALB-TG" {
  name     = "webserver-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.MainVPC.id

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

resource "aws_launch_template" "WebServerLT" {
  name          = "web-server-launch-template"
  description   = "Web Server ASG Template"
  image_id      = var.amazon_linux_ami
  instance_type = var.asg_instance_type
  key_name      = var.asg_instance_key

  vpc_security_group_ids = [aws_security_group.WebServerSG.id]
  user_data              = base64encode(file("${path.module}/userdata.sh"))

  //ebs_optimized = true
  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 10
    }
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "WebServer-LT"
    }
  }
}

resource "aws_autoscaling_group" "WebServerASG" {
  name_prefix         = "webserver-asg-"
  vpc_zone_identifier = [aws_subnet.PrivateSubnetOne.id]
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1
  #wait_for_capacity_timeout = 0
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [aws_alb_target_group.ALB-TG.arn]

  launch_template {
    id      = aws_launch_template.WebServerLT.id
    version = "$Latest"
  }
}

