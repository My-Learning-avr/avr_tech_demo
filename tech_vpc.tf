# Defination the VPC
resource "aws_vpc" "tech_vpc" {
  cidr_block            = "${var.vpc_cidr}"
  enable_dns_hostnames  = true
  tags      = {
    Name    = "tech_vpc"
  }
}

# Defination the Internet GateWay and attaching to the tech_vpc
resource "aws_internet_gateway" "tech_igw" {
  vpc_id    = aws_vpc.tech_vpc.id
  tags      = {
    Name    = "tech_igw"
  }
}

# Defination of public subnet web1[web tier]
resource "aws_subnet" "public_subnet_web1" {
  vpc_id                  = aws_vpc.tech_vpc.id
  cidr_block              = "${var.public_subnet_web1_cidr}"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags      = {
    Name    = "public_subnet_web1"
  }
}

# Defination of public subnet web2[web tier]
resource "aws_subnet" "public_subnet_web2" {
  vpc_id                  = aws_vpc.tech_vpc.id
  cidr_block              = "${var.public_subnet_web2_cidr}"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags      = {
    Name    = "public_subnet_web2"
  }
}

# Defination of public RouteTable
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.techvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tech_igw.id
  }

  tags      = {
    Name    = "public_rt"
  }
}

# Defination of public RouteTable association with web1
resource "aws_route_table_association" "public_subnet_web1_rt_association" {
  subnet_id      = aws_subnet.public_subnet_web1.id
  route_table_id = aws_route_table.public_rt.id
}

# Defination of public RouteTable association with web2
resource "aws_route_table_association" "public_subnet_web2_rt_association" {
  subnet_id      = aws_subnet.public_subnet_web2.id
  route_table_id = aws_route_table.public_rt.id
}

# Defination of private subnet app1[app tier]
resource "aws_subnet" "private_subnet_app1" {
  vpc_id                  = aws_vpc.tech_vpc.id
  cidr_block              = "${var.private_subnet_app1_cidr}"
  availability_zone       = "us-east-1a"
  map_private_ip_on_launch = true
  tags      = {
    Name    = "private_subnet_app1"
  }
}

# Defination of private subnet app2[app tier]
resource "aws_subnet" "private_subnet_app2" {
  vpc_id                  = aws_vpc.tech_vpc.id
  cidr_block              = "${var.private_subnet_app2_cidr}"
  availability_zone       = "us-east-1b"
  map_private_ip_on_launch = true
  tags      = {
    Name    = "private_subnet_app2"
  }
}

# Defination of private subnet db1[db tier]
resource "aws_subnet" "private_subnet_db1" {
  vpc_id                  = aws_vpc.tech_vpc.id
  cidr_block              = "${var.private_subnet_db1_cidr}"
  availability_zone       = "us-east-1a"
  map_private_ip_on_launch = true
  tags      = {
    Name    = "private_subnet_db1"
  }
}

# Defination of private subnet db2[db tier]
resource "aws_subnet" "private_subnet_db2" {
  vpc_id                  = aws_vpc.tech_vpc.id
  cidr_block              = "${var.private_subnet_db2_cidr}"
  availability_zone       = "us-east-1b"
  map_private_ip_on_launch = true
  tags      = {
    Name    = "private_subnet_db2"
  }
}

# Defination of ElasticIP for NAT GateWay
resource "aws_eip" "elastic_ip_nat_gw" {
  vpc = true

  tags      = {
    Name    = "elastic_ip_nat"
  }
}

# Defination of NAT GateWay
resource "aws_nat_gateway" "tech_nat_gw" {
  allocation_id = aws_eip.elastic_ip_nat_gw.id
  subnet_id     = aws_subnet.public_subnet_web2.id

  tags = {
    "Name" = "tech_nat_gw"
  }
}

# Defination of private RouteTable
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.tech_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tech_nat_gw.id
  }

  tags      = {
    Name    = "private_rt"
  }
}

# Defination of private RouteTable association with app1
resource "aws_route_table_association" "private_subnet_app1_rt_association" {
  subnet_id      = aws_subnet.private_subnet_app1.id
  route_table_id = aws_route_table.private_rt.id
}

# Defination of private RouteTable association with app2
resource "aws_route_table_association" "private_subnet_app2_rt_association" {
  subnet_id      = aws_subnet.private_subnet_app2.id
  route_table_id = aws_route_table.private_rt.id
}

# Defination of private RouteTable association with db1
resource "aws_route_table_association" "private_subnet_db1_rt_association" {
  subnet_id      = aws_subnet.private_subnet_db1.id
  route_table_id = aws_route_table.private_rt.id
}

# Defination of private RouteTable association with db2
resource "aws_route_table_association" "private_subnet_db2_rt_association" {
  subnet_id      = aws_subnet.private_subnet_db2.id
  route_table_id = aws_route_table.private_rt.id
}

# Defination of security group for application load balancer
resource "aws_security_group" "tech_alb_sg" {
  name        = "ALB Security Group"
  description = "Enable http/https access on port 80/443"
  vpc_id      = aws_vpc.tech_vpc.id

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https access"
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
    Name = "tech_alb_sg"
  }
}

# Defination of security group for application tier
resource "aws_security_group" "tech_app_sg" {
  name        = "SSH Access"
  description = "Enable ssh access on port 22"
  vpc_id      = aws_vpc.tech_vpc.id

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_ip}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tech_app_sg"
  }
}

# Defination of security group for web tier
resource "aws_security_group" "tech_web_sg" {
  name        = "Web tier Security Group"
  description = "Enable http/https access on port 80/443"
  vpc_id      = aws_vpc.tech_vpc.id

  ingress {
    description     = "http access"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.tech_alb_sg.id}"]
  }

  ingress {
    description     = "https access"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.tech_alb_sg.id}"]
  }
  ingress {
    description     = "ssh access"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.tech_app_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tech_web_sg"
  }
}

# Defination of security group for database tier
resource "aws_security_group" "tech_db_sg" {
  name        = "Database server Security Group"
  description = "Enable MYSQL access on port 3306"
  vpc_id      = aws_vpc.tech_vpc.id

  ingress {
    description     = "MYSQL access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.tech_web_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags    = {
    Name  = "tech_db_sg"
  }
}

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


# Defination of database subnets
resource "aws_db_subnet_group" "tech_db_subnets_group" {
  name        = "database subnets"
  subnet_ids  = [aws_subnet.private_subnet_db1.id, aws_subnet.private_subnet_db2.id]
  description = "Subnet group for database instance"

  tags = {
    Name = "tech_db_subnets_group"
  }
}

# Defination of mysql database instance 
resource "aws_db_instance" "tech_mysql_db" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "${var.db_instance}"
  db_name                = "mysqldb"
  username               = "techmysqldb"
  password               = "techmysqldb"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  availability_zone      = "us-east-1b"
  db_subnet_group_name   = aws_db_subnet_group.tech_db_subnets_group.name
  multi_az               = "${var.multi_az_defination}"
  vpc_security_group_ids = [aws_security_group.tech_db_sg.id]
}
