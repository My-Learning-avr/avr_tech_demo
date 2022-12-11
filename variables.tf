# CIDR variable for the VPC
variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# CIDR variable for the web1
variable "public_subnet_web1_cidr" {
  default     = "10.0.1.0/24"
  description = "public_subnet_web1"
  type        = string
}

# CIDR variable for the web2
variable "public_subnet_web2_cidr" {
  default     = "10.0.2.0/24"
  description = "public_subnet_web2"
  type        = string
}

# CIDR variable for the app1
variable "private_subnet_app1_cidr" {
  default     = "10.0.3.0/24"
  description = "private_subnet_app1"
  type        = string
}

# CIDR variable for the app2
variable "private_subnet_app2_cidr" {
  default     = "10.0.4.0/24"
  description = "private_subnet_app2"
  type        = string
}

# CIDR variable for the db1
variable "private_subnet_db1_cidr" {
  default     = "10.0.5.0/24"
  description = "private_subnet_db1"
  type        = string
}

# CIDR variable for the db2
variable "private_subnet_db2_cidr" {
  default     = "10.0.6.0/24"
  description = "private_subnet_db2"
  type        = string
}

# security group for application tier
variable "ssh_ip" {
  default     = "117.201.220.172/32" #local system ipconfig has to be updated 
  description = "ip address"
  type        = string
}

# Db instance 
variable "db_instance" {
  default     = "db.t2.micro"
  description = "The Database Instance type"
  type        = string
}

# Multi AZ defination
variable "multi_az_defination" {
  default     = false
  description = "Create a Standby DB Instance"
  type        = bool
}