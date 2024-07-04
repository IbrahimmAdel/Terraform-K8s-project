provider "aws" {
  region = "us-east-1"
}


terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}
