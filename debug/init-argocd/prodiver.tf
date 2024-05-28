terraform {
  required_providers {
    huaweicloud = {
      source = "huaweicloud/huaweicloud"
      version = ">= 1.20.0"
    }
  }
  required_version = ">= 0.13"

  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.21.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
  }

  # backend "s3" {
  #   bucket   = "devops"
  #   key      = "init/terraform/terraform.tfstate"
  #   region   = "ap-southeast-3"
  #   endpoint = "devops.obs.ap-southeast-3.myhuaweicloud.com"

  #   skip_region_validation      = true
  #   skip_metadata_api_check     = true
  #   skip_credentials_validation = true
  # }
}

provider "huaweicloud" {
  region = "ap-southeast-3"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.cluster_name
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = var.cluster_name
  }
}