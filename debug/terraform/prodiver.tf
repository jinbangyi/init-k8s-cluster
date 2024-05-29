terraform {
  required_providers {
    huaweicloud = {
      source = "huaweicloud/huaweicloud"
      version = ">= 1.20.0"
    }

    # null_resource = {
    #   source = "hashicorp/null"
    #   version = ">= 3.2.2"
    # }
  }
  required_version = ">= 0.13"

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
