resource "aws_security_group" "application_sg" {
  name        = "application-security-group"
  description = "Allow web and SSH access"
  vpc_id      = aws_vpc.main["vpc1"].id # Choose your VPC (e.g., vpc1)

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Application Port"
    from_port   = 8080 # Flask app default port (modify as required)
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   description     = "Allow MySQL from EC2"
  #   from_port       = 3306
  #   to_port         = 3306
  #   protocol        = "tcp"
  #   security_groups = [aws_security_group.application_sg.id] # Allow EC2 access to RDS
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "application-security-group"
  }
}

//loadbalancer
resource "aws_security_group" "load_balancer_sg" {
  name        = "load-balancer-sg"
  description = "Security group for the load balancer"
  for_each    = var.vpcs
  vpc_id      = aws_vpc.main[each.key].id
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

  tags = {
    Name = "tf-load-balancer-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "webapp_lb" {
  name               = "csye6225-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_sg["vpc1"].id]
  subnets            = [for k, s in aws_subnet.public_subnets : s.id]

  tags = {
    Name = "csye6225-lb"
  }
}

# Target Group
resource "aws_lb_target_group" "webapp_tg" {
  name     = "webapp-tg"
  port     = 8080
  protocol = "HTTP"
  for_each = var.vpcs
  vpc_id   = aws_vpc.main[each.key].id

  health_check {
    path                = "/healthz"
    port                = 8080
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }
}

# Listener (HTTP on port 80)
resource "aws_lb_listener" "webapp_listener" {
  load_balancer_arn = aws_lb.webapp_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_tg["vpc1"].arn
  }
}

# Auto-Scaling Group
resource "aws_autoscaling_group" "webapp_asg" {
  name                = "csye6225-asg"
  min_size            = 3
  max_size            = 5
  desired_capacity    = 3
  vpc_zone_identifier = [for k, s in aws_subnet.public_subnets : s.id]
  target_group_arns   = [aws_lb_target_group.webapp_tg["vpc1"].arn]

  launch_template {
    id      = aws_launch_template.webapp_lt.id
    version = "$Latest"
  }

  # Cooldown period
  default_cooldown = 60

  # Tags
  tag {
    key                 = "Name"
    value               = "tf-aws-web-app"
    propagate_at_launch = true
  }
}

# Scaling Policies
# Scale Up Policy (CPU > 5%)
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}

# Scale Down Policy (CPU < 3%)
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}

# CloudWatch Alarms for Scaling
# Scale Up Alarm (CPU > 5%)
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "scale-up-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
}

# Scale Down Alarm (CPU < 3%)
resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "scale-down-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 3
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
}

# Route 53 Record for the current profile 
resource "aws_route53_record" "environment_record" {
  zone_id = var.route53_zone_id
  name    = "${var.subdomain}.${var.domain_name}"
  type    = "A"
  alias {
    name                   = aws_lb.webapp_lb.dns_name
    zone_id                = aws_lb.webapp_lb.zone_id
    evaluate_target_health = true
  }
}
