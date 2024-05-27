variable "rds_name" {
    type = string
    default = "prod-k8s_pg"
}

data "huaweicloud_rds_instance" "k8s_pg" {
    name = var.rds_name
}

output master_value {
  # Ids for multiple sets of EC2 instances, merged together
  value = data.huaweicloud_rds_instance.k8s_pg
}
