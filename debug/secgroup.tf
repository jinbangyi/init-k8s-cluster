# 创建安全组
# 创建整个环境默认安全组
resource "huaweicloud_networking_secgroup" "prod_default" {
  name                 = "prod_default"
  description          = "prod_default"
  delete_default_rules = false
}

# 创建 production-private 子网默认安全组
resource "huaweicloud_networking_secgroup" "prod_private-default" {
  name                 = "prod_private-default"
  description          = "prod_private-default"
  delete_default_rules = false
}

# 创建 production-public 子网默认安全组
resource "huaweicloud_networking_secgroup" "prod_public-default" {
  name                 = "prod_public-default"
  description          = "prod_public-default"
  delete_default_rules = false
}

# 创建 production-private_devops 子网默认安全组
resource "huaweicloud_networking_secgroup" "prod_private_devops-default" {
  name                 = "prod_private_devops-default"
  description          = "prod_private_devops-default"
  delete_default_rules = false
}

# 创建 production-private_db 子网默认安全组
resource "huaweicloud_networking_secgroup" "prod_private_db-default" {
  name                 = "prod_private_db-default"
  description          = "prod_private_db-default"
  delete_default_rules = false
}

# 创建 api 网关的安全组
resource "huaweicloud_networking_secgroup" "prod_private-http_gateway" {
  name                 = "prod_private-http_gateway"
  description          = "prod_private-http_gateway"
  delete_default_rules = false
}

# 创建 api 网关的安全规则
resource "huaweicloud_networking_secgroup_rule" "secgroup_rule1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.prod_private-http_gateway.id
}

# 创建 api 网关的安全规则
resource "huaweicloud_networking_secgroup_rule" "secgroup_rule2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.prod_private-http_gateway.id
}

# 创建 jumpserver 安全组
resource "huaweicloud_networking_secgroup" "prod_public-jumpserver" {
  name                 = "prod_public-jumpserver"
  description          = "prod_public-jumpserver"
  delete_default_rules = false
}

# 创建 jumpserver 安全组规则
resource "huaweicloud_networking_secgroup_rule" "secgroup_rule3" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2222
  port_range_max    = 2222
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.prod_public-jumpserver.id
}
