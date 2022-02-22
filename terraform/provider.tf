terraform {
  required_providers {
    aws       = {
      source  = "hashicorp/aws"
      version = "4.2.0" # strict pinning
    }
    archive   = {
      source  = "hashicorp/archive"
      version = "2.2.0"
    }
    template  = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

# Configure the AWS Provider
provider aws {
  region = "us-east-1"
  profile = "personal"
  default_tags {
    tags                 = {
      description        = "measurabl take-home test"
      isTerraformManaged = "true"
      owner              = "josh.sarver"
      Name               = "measurabl"
    }
  }
}
