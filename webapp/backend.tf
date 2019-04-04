terraform {
  backend "s3" {
    bucket = "openchs"
    region = "ap-south-1"
    encrypt = "true"
    key = "terraform-webapp-state"
  }
}
