terraform {
  backend "s3" {
    bucket = "measurabl-terraform"
    key    = "terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
