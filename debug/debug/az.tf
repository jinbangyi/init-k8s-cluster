data "huaweicloud_availability_zones" "default" {}

output master_value {
  # Ids for multiple sets of EC2 instances, merged together
  value = data.huaweicloud_availability_zones.default
}
