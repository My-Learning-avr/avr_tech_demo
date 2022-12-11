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



