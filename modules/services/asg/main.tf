resource "aws_security_group" "WebServerSG" {
  name        = "WebServerSG"
  description = "Allow basic administration"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.asg_sg_ports
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = [ "0.0.0.0/0" ]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "WebServerSG"
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
  vpc_zone_identifier = var.private_subnets
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  #wait_for_capacity_timeout = 0
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [var.alb_tg_arn]

  launch_template {
    id      = aws_launch_template.WebServerLT.id
    version = "$Latest"
  }
}


resource "aws_autoscaling_policy" "autoscaling_policy_webserver" {
  autoscaling_group_name = aws_autoscaling_group.WebServerASG.name
  name = "webserver-autoscaling-policy"
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }

}