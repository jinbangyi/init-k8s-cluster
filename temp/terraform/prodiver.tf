terraform {
  required_providers {
    huaweicloud = {
      source = "huaweicloud/huaweicloud"
      version = ">= 1.20.0"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    bucket   = "devops"
    key      = "init/terraform/terraform.tfstate"
    region   = "ap-southeast-3"
    endpoint = "devops.obs.ap-southeast-3.myhuaweicloud.com"

    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_credentials_validation = true
  }
}

provider "huaweicloud" {
  region = "ap-southeast-3"
  domain_name = "hid_0slzn64o_u69hyk"
  project_name = "ap-southeast-3"
}

variable "do_token" {}
variable "pvt_key" {}
variable "database_user" {}

variable "nodes" {
  type = set(object({
    name = string
    tag  = string
  }))
  default = [
    {
      name = "master1"
      tag  = "master"
    },
    {
      name = "master2",
      tag  = "master"
    },
    {
      name = "agent1",
      tag  = "agent"
      }, {
      name = "agent2",
      tag  = "agent"
    },
    {
      name = "agent3",
      tag  = "agent"
    }
  ]
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "terraform" {
  name = "Batuhan-MBP"
}
