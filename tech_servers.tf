# Defination of ubuntu AMI
data "aws_ami" "ubuntu" {

    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

# Defination of EC2 for web tier
resource "aws_instance" "tech_web_ec2_template" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet_web1.id
  vpc_security_group_ids = [aws_security_group.tech_web_sg.id]
  key_name               = "tech_key"
  user_data              = file("install_httpd.sh")

  tags      = {
    Name    = "tech_web_ec2_template"
  }
}

# Defination of EC2 for app tier
resource "aws_instance" "tech_app_ec2_template" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet_app1.id
  vpc_security_group_ids = [aws_security_group.tech_app_sg.id]
  key_name               = "tech_key"

  tags      = {
    Name    = "tech_app_ec2_template"
  }
}

# Defination of EC2 for Auto scaling group template for web tier
resource "aws_launch_template" "tech_asg_template_web" {
  name_prefix   = "auto-scaling-group"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = "tech_key"
  network_interfaces {
    subnet_id       = aws_subnet.public_subnet_web1.id
    security_groups = [aws_security_group.tech_web_sg.id]
  }
}

# Defination of EC2 for Auto scaling group web tier
resource "aws_autoscaling_group" "tech_asg_web" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
    id      = aws_launch_template.tech_asg_template_web.id
    version = "$Latest"
  }
}

# Defination of EC2 for Auto scaling group template for app tier
resource "aws_launch_template" "tech_asg_template_app" {
  name_prefix   = "auto-scaling-group-private"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = "tech_key"

  network_interfaces {
    subnet_id       = aws_subnet.public_subnet_app1.id
    security_groups = [aws_security_group.tech_app_sg.id]
  }
}

# Defination of EC2 for Auto scaling group for app tier
resource "aws_autoscaling_group" "tech_asg_app" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
    id      = aws_launch_template.tech_asg_template_app.id
    version = "$Latest"
  }
}

# Defination of application load balaner
resource "aws_lb" "tech_alb" {
  name                       = "web-external-load-balancer"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.tech_alb_sg.id]
  subnets                    = [aws_subnet.public_subnet_web1.id, aws_subnet.public_subnet_web2.id]
  enable_deletion_protection = false

  tags = {
    Name = "tech_alb"
  }
}

# Defination of application load balaner target group
resource "aws_lb_target_group" "tech_alb_tg" {
  name     = "tech_alb_tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tech_vpc.id
}

# Defination of application load balaner target group attachment with web tier
resource "aws_lb_target_group_attachment" "web-attachment" {
  target_group_arn = aws_lb_target_group.tech_alb_tg.arn
  target_id        = aws_instance.tech_web_ec2_template.id
  port             = 80
}

# Defination of listener on port 80 with redirect action
resource "aws_lb_listener" "tech_alb_http_listener" {
  load_balancer_arn = aws_lb.tech_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

