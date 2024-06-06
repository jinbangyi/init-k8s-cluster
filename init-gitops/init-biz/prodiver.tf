terraform {
  required_providers {
    huaweicloud = {
      source = "huaweicloud/huaweicloud"
      version = ">= 1.20.0"
    }

  }
  required_version = ">= 0.13"
}

provider "huaweicloud" {
  region = "ap-southeast-3"
}
