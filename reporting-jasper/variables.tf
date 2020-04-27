variable "region" {
  type        = "string"
  description = "AWS Region"
  default     = "ap-south-1"
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
  description = "ECS Instance Type"
  default     = "t2.medium"
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

//variable "metabase_version" {
//  description = "Metabase version to install"
//  default     = "v0.32.4"
//}

variable "instance_count" {
  description = "Metabase instance count"
  default     = 1
}
