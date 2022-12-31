

resource "aws_instance" "terraform-ec2" {
  ami           = "ami-0e472ba40eb589f49"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${aws_security_group.terraform-sg.id}"]
  subnet_id                   = "${aws_subnet.public-subnet-1.id}"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.terraform-sg.id]


 tags = {
  Name = "Terraform-EC2"

 }

}

#==========================#

resource "aws_db_subnet_group" "subnet-group" {
name = "db subnet group"
subnet_ids = ["${aws_subnet.private-subnet-1.id}", "${aws_subnet.private-subnet-2.id}"] 

}

resource "aws_db_instance" "rds-instance" {
  allocated_storage    = var.allocated_storage
  storage_type         = var.storage_type
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  username             = var.username
  password             = var.password
  db_name              = var.name
  parameter_group_name = var.parameter_group_name
  skip_final_snapshot = var.skip_final_snapshot
  db_subnet_group_name   = aws_db_subnet_group.subnet-group.name
  vpc_security_group_ids = [aws_security_group.rds-sg.id]

}

#=====================#

terraform {
  backend "s3" {
    bucket = "terraform-bucket-demo2"
    key    = "key/statefile"
    region = "us-east-1"
  }
}


#----------------------#


resource "aws_launch_template" "Terraform-template" {
  name_prefix   = "Terraform-template"
  image_id      = "ami-0c4f7023847b90238"
  instance_type = "t2.micro"
  

  
}

#--------------elb----------#

resource "aws_elb" "terrafom-elb" {
  name    = "terraform-elb"
  subnets = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
  security_groups = [aws_security_group.terraform-elb-sg.id]


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
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "terraform-elb"
  }
}

resource "aws_lb_target_group" "alb-target-group" {
  name        = "alb-target-group"
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.vpc.id
}


resource "aws_autoscaling_group" "terraform-ASG" {
name                      = "terraform-ASG"
vpc_zone_identifier       = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
desired_capacity          = 1
min_size                  = 1
max_size                  = 2
health_check_grace_period = 120
health_check_type         = "ELB"
force_delete = true

tag {
    key                 = "Name"
    value               = "Terraform-ec2-instance"
    propagate_at_launch = true
  }
   launch_template {
    id      = aws_launch_template.Terraform-template.id
    version = "$Latest"
  }
  
}

resource "aws_autoscaling_policy" "terraform-ASG-policy" {
  name                   = "terraform-ASG-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.terraform-ASG.name
  policy_type            = "SimpleScaling"
}


resource "aws_cloudwatch_metric_alarm" "terrafom-alarm" {
  alarm_name                = "terraform-alarm"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "50"

 dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.terraform-ASG.name
  }
  actions_enabled = true
  alarm_actions     = [aws_autoscaling_policy.terraform-ASG-policy.arn]

}

#--------------------descaling--------------#


resource "aws_autoscaling_policy" "terraform-ASG-policy-scaledown" {
  name                   = "terraform-ASG-policy-scaledown"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.terraform-ASG.name
  policy_type            = "SimpleScaling"
}


resource "aws_cloudwatch_metric_alarm" "terrafom-alarm-scaledown" {
  alarm_name                = "terraform-alarm-scaledown"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "10"




 dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.terraform-ASG.name
  }
  actions_enabled = true
  alarm_actions     = [aws_autoscaling_policy.terraform-ASG-policy-scaledown.arn]

}
