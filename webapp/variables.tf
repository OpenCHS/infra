variable "default_ami_user" {
  type = "string"
  default = "ec2-user"
}
variable "key_name" {
  description = "Key Name"
  default     = "openchs-infra"
}
variable "circle_build_num" {
  type = "string"
}
