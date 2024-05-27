variable "lb_name" {
    type = string
    default = "prod_master"
}

data "huaweicloud_lb_loadbalancer" "prod_master" {
    name = var.lb_name
}

output master_value {
  # Ids for multiple sets of EC2 instances, merged together
  value = data.huaweicloud_lb_loadbalancer.prod_master
}
