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