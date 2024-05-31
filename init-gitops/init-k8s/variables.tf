variable "prod_master_domain" {
  type = string
}

variable "prod_ecs_keypair" {
  type = string
  default = "huawei-manager"
}

variable "prod_ecs_image_name" {
  type = string
}
