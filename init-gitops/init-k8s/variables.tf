variable "prod_master_domain" {
  type = string
  default = "master-api.prod.nftgo.dev"
}

variable "prod_ecs_keypair" {
  type = string
  default = "huawei-manager"
}

variable "prod_ecs_image_name" {
  type = string
}
