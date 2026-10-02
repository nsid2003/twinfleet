data "aws_ssm_parameter" "ami" {
  name = var.ami_ssm_parameter
}

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name
}

resource "aws_launch_template" "app" {
  name_prefix            = "${var.name_prefix}-lt-"
  image_id               = data.aws_ssm_parameter.ami.insecure_value
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.app_sg_id]
  user_data              = filebase64("${path.module}/user_data.sh")
  update_default_version = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2.arn
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(var.instance_tags, {
      Name = "${var.name_prefix}-app-volume"
    })
  }
}

resource "aws_lb_target_group" "app" {
  name                 = "${var.name_prefix}-tg"
  port                 = var.app_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 30

  health_check {
    path                = var.health_check_path
    matcher             = "200"
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb" "app" {
  name                       = "${var.name_prefix}-alb"
  load_balancer_type         = "application"
  internal                   = false
  security_groups            = [var.alb_sg_id]
  subnets                    = var.public_subnet_ids
  drop_invalid_header_fields = true
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_autoscaling_group" "app" {
  name                      = "${var.name_prefix}-asg"
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  vpc_zone_identifier       = var.app_subnet_ids
  target_group_arns         = [aws_lb_target_group.app.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app.id
    version = aws_launch_template.app.latest_version
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-app"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.instance_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
