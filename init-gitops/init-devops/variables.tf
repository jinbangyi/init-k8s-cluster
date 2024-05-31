variable "prod_k8s_token" {
  type = string
}

variable "prod_jumpserver_ip" {
  type = string
}

variable "prod_ecs_keypair" {
  type = string
  default = "huawei-manager"
}

variable "prod_master_lb" {
  type = string
}

variable "prod_ecs_image_name" {
  type = string
}
