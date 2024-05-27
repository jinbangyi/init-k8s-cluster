data "huaweicloud_lb_loadbalancer" "prod_master" {}

output master_value {
  # Ids for multiple sets of EC2 instances, merged together
  value = data.huaweicloud_lb_loadbalancer.prod_master
}
