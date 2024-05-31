data "huaweicloud_networking_secgroup" "prod_default" {
  name                 = "prod_default"
}

data "huaweicloud_networking_secgroup" "prod_private-default" {
  name                 = "prod_private-default"
}

# 创建 api 网关的安全组
resource "huaweicloud_networking_secgroup" "prod_private-http_gateway" {
  name                 = "prod_private-http_gateway"
  description          = "prod_private-http_gateway"
  delete_default_rules = false
}

resource "huaweicloud_networking_secgroup_rule" "secgroup_rule1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.prod_private-http_gateway.id
}

resource "huaweicloud_networking_secgroup_rule" "secgroup_rule2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.prod_private-http_gateway.id
}
