terraform {
  required_version = ">= 1.5"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.25"
    }
  }
}