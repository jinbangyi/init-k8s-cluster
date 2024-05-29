data "huaweicloud_networking_secgroup" "prod_default" {
  name                 = "prod_default"
}

data "huaweicloud_networking_secgroup" "prod_private-default" {
  name                 = "prod_private-default"
}
