variable "region" {
  type = "string"
  description = "AWS Region"
  default = "us-east-1"
}


variable "ami" {
  type = "string"
  description = "RHEL hvm:ebs-ssd AMI Virginia"
  default = "ami-c998b6b2"
}

variable "default_ami_user" {
  type = "string"
  default = "ec2-user"
}

variable "instance_type" {
  type = "string"
  description = "EC2 Instance Type"
  default = "t2.micro"
}

variable "instance_type_es" {
  type = "string"
  description = "ES Instance Type"
  default = "t2.medium"
}

variable "disk_size" {
  description = "Size of the disks for EC2 Instances"
  default = 20
}

variable "key_name" {
  description = "Key Name"
  default = "openchs-infra"
}