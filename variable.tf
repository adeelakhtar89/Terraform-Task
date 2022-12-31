# Variables
variable "region" {
  default       = "us-east-1"
  description   = "AWS Region"
  type          = string
}

variable "vpc-cidr" {
  default       = "10.0.0.0/26"
  description   = "VPC CIDR Block"
  type          = string
}

variable "public-subnet-1-cidr" {
  default       = "10.0.0.0/28"
  description   = "Public Subnet 1 CIDR Block"
  type          = string
}

variable "public-subnet-2-cidr" {
  default       = "10.0.0.32/28"
  description   = "Public Subnet 2 CIDR Block"
  type          = string
}

variable "private-subnet-1-cidr" {
  default       = "10.0.0.16/28"
  description   = "Private Subnet 1 CIDR Block"
  type          = string
}

variable "private-subnet-2-cidr" {
  default       = "10.0.0.48/28"
  description   = "Private Subnet 2 CIDR Block"
  type          = string
}


#----------------------#

variable "ssh-location" {
default = "0.0.0.0/0"
description = "SSH variable ec2"
type = string
}
variable "instance_type" {
type        = string
default     = "t2.micro"
}
variable key_name {
default     = "TF-ec2-key"
type = string
}


#-------------------#

variable "allocated_storage" {
  default = 20
  description = "Allocated storage of RDS instance"

}

variable "storage_type" {
  default = "gp2"
}

variable "engine" {
  default = "mysql"
}

variable "engine_version" {
  default = "8.0"
}

variable "instance_class" {
  default = "db.t2.micro"
}

variable "username" {
  default = "adeel"
}

variable "password" {
  default = "adeel123"
}

variable "name" {
  default = "db"
}

variable "parameter_group_name" {
  default = "default.mysql8.0"
}

variable "skip_final_snapshot" {
  default = true
}

