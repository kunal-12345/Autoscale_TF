data "template_file" "user_data" {
  template = "${file("user_data.tpl")}"

  vars {
    db_name = "${var.db_name}"
    db_username = "${var.db_username}"
    db_password = "${var.db_password}"
    db_host = "${aws_db_instance.wp_rds.endpoint}"
    site_url = "${aws_elb.wp_elb.dns_name}"
    site_title = "${var.site_title}"
    site_admin_name = "${var.admin_user}"
    site_admin_password = "${var.admin_password}"
    site_admin_email = "${var.admin_email}"
  }
}

resource "aws_security_group" "wp_instance_security_group" {
  name        = "AutoScaling-Security-Group-1"
  description = "AutoScaling-Security-Group-1 desc..."

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/20"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/20"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/20"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id = "${vpc-fed72b96.id}"

}

resource "aws_launch_configuration" "Aaaa" {
  name_prefix   = "Aaaa-instance-"
  image_id      = "ami-bd1830d8"
  instance_type = "t2.micro"
  key_name = "${var.At-PB}"
  security_groups = ["${sg-1debec75.id}"]
  associate_public_ip_address = false
  user_data = "${data.template_file.user_data.rendered}"

  root_block_device {
    volume_size = "50"
    volume_type = "gp2"
  }

}

resource "aws_autoscaling_group" "Caabbb" {
  name                      = "Caabbb"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = true
  launch_configuration      = "${Aaaa}"
  min_elb_capacity          = 1
  vpc_zone_identifier       = ["${aws_subnet.wp_private_subnet_a.id}", "${aws_subnet.wp_private_subnet_b.id}"]
  load_balancers            = ["${aws_elb.wp_elb.name}"]

  tag {
    key                 = "Name"
    value               = "${Caabbb}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Baaa"
    value               = "${var.Baaa}"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_policy" "Increase Group Size" {
    name = "Increase Group Size"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${Baaa}"
}

resource "aws_autoscaling_policy" "Decrease Group Size" {
    name = "Decrease Group Size"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${Baaa}"
}

resource "aws_cloudwatch_metric_alarm" "wp_memory_high" {
    alarm_name = "awsec2-edsdc-CPU-Utilization"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "System/Linux"
    period = "300"
    statistic = "Average"
    threshold = "30"
    alarm_description = "This metric monitors ec2 memory for high utilization on WordPress hosts"
    alarm_actions = [
        "${aws_autoscaling_policy.wp_scale_up.arn}"
    ]
    dimensions {
        AutoScalingGroupName = "${aws_autoscaling_group.wp_autoscaling_group.name}"
    }
}

resource "aws_cloudwatch_metric_alarm" "wp_memory_low" {
    alarm_name = "mem-util-low"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "MemoryUtilization"
    namespace = "System/Linux"
    period = "300"
    statistic = "Average"
    threshold = "20"
    alarm_description = "This metric monitors ec2 memory for low utilization on Autoscaling"
    alarm_actions = [
        "${aws_autoscaling_policy.wp_scale_up.arn}"
    ]
    dimensions {
        AutoScalingGroupName = "${Baaa}"
    }
}

resource "aws_security_group" "wp_elb_security_group" {
  name        = "AutoScaling-Security-Group-1"
  description = "AutoScaling-Security-Group-1 desc..."

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/20", "${var.elb_outbound_ip}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16", "${var.elb_outbound_ip}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id = "${vpc-fed72b96.id}"
}

resource "aws_elb" "wp_elb" {
  name               = "wp-elb"
  subnets            = ["${subnet-0a105447.id}", "${subnet-2fe92f47.id}"]
  security_groups    = ["${sg-be4178d6.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 500

  tags {
    Name        = "wp_database_server"
    Owner       = "${var.kunal.lade}"
    Project     = "${var.project}"
    Environment = "${var.Caabbb}"
  }
}

resource "aws_lb_cookie_stickiness_policy" "wp_lb_stickiness" {
  name                     = "step scaling"
  load_balancer            = "${aws_elb.wp_elb.id}"
  lb_port                  = 80
  cookie_expiration_period = 3600
}
