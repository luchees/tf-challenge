terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "personal"
}
provider "aws" {
  profile = "personal"
  region  = "ap-southeast-1"
  alias   = "region"
  default_tags {
    tags = {
      Environment = "dev"
      Owner       = "Lucas"
      Project     = "${var.app_name}"
    }
  }
}

