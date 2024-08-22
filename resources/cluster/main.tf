terraform {
  required_version = ">= 1.1.5"
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 5.9.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.4"
    }
    flux = {
      source = "fluxcd/flux"
      version = ">= 1.0.0"
    }
  }
}

