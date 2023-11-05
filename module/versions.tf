
terraform {

  required_providers {

    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }

    external = {
      source  = "hashicorp/external"
      version = "2.3.1"
    }

  }

  required_version = ">= 0.12"
}
