variable "default_ami_user" {
  type = "string"
  default = "ec2-user"
}

variable "key_name" {
  description = "Key Name"
  default     = "openchs-infra"
}

variable "environment" {
  type        = "string"
  description = "Environment Name"
  default     = "staging"
}

variable "url_map" {
  type        = "map"
  description = "URL Map"

  default = {
    demo    = "demo"
    uat    = "uat"
    staging = "staging"
    prod    = "server",
    prerelease = "prerelease"
  }
}

variable "server_name" {
  type = "string"
  default = "openchs.org"
}
