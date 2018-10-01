variable "region" {
  type        = "string"
  description = "AWS Region"
  default     = "ap-south-1"
}

variable "environment" {
  type        = "string"
  description = "Environment Name"
  default     = "staging"
}

variable "cidr_map" {
  type        = "map"
  description = "CIDR Map"

  default = {
    demo    = "10.10.0.0/16"
    uat    = "10.30.0.0/16"
    staging = "10.20.0.0/16"
    prod    = "10.100.0.0/16"
  }
}

variable "db_final_snapshot" {
  type = "map"

  default = {
    demo = false
    uat = true
  }
}

variable "disable_api_termination" {
  type = "map"

  default = {
    prod = true
  }
}

variable "db_ssd_type" {
  type = "map"

  default = {
    prod = "gp2"
  }
}

variable "url_map" {
  type        = "map"
  description = "URL Map"

  default = {
    demo    = "demo"
    uat    = "uat"
    staging = "staging"
    prod    = "server"
  }
}

variable "ami" {
  type        = "string"
  description = "Amazon Linux hvm:ebs-ssd AMI Mumbai"
  default     = "ami-531a4c3c"
}

variable "default_ami_user" {
  type    = "string"
  default = "ec2-user"
}

variable "instance_type" {
  type        = "string"
  description = "EC2 Instance Type"
  default     = "t2.micro"
}

variable "instance_map" {
  type = "map"

  default = {
    prod = "t2.medium"
  }
}

variable "disk_size" {
  description = "Size of the disks for EC2 Instances"
  default     = 20
}

variable "ssh_public_key" {
  description = "Public Key used to ssh into the instances"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCCn43kM4aumjyp/PuQFJrIiENhBXiwVdkje0SNmMFllvyy6LZQoZ86yi4KrnePGAw0aJLY9oViFsR/Ib8qzULYKSM1M5D7tPsdhb/1Tyv5DYFZxpDQTsrW134xQfB01E53n65KItjyQ2H9nh1Xyop2wDHZUDIdBAUWDj4Bb3uqVUfwiMBn/Jk2eACl42pbeD7zVOJgUZYiJx8/DlYhiPRofwtnn1DUKjPjYosnwBbvUfuIhfYEk1TsTAW49MJI163TBAZqj8bylo/WqSI/U2D1N0Njh1WiXrHywGJHWrN8SNUvZL50D87dq3iUWkz5RPcrvVi5eJBhHHk6ieGExmZH"
}

variable "key_name" {
  description = "Key Name"
  default     = "openchs-infra"
}

variable "server_port" {
  description = "Server Port"
  default     = 8021
}

variable "fromDB" {
  type        = "string"
  description = "From Database"
  default     = "staging"
}

variable "bugsnag_api_key" {
  type        = "string"
  description = "From Database"
  default = ""
}