# 创建安全组
# 创建整个环境默认安全组
resource "huaweicloud_networking_secgroup" "production-default" {
  name                 = "production-default"
  description          = "production-default"
  delete_default_rules = false
}

# 创建 production-private 子网默认安全组
resource "huaweicloud_networking_secgroup" "production-private-default" {
  name                 = "production-private-default"
  description          = "production-private-default"
  delete_default_rules = false
}

# 创建 production-public 子网默认安全组
resource "huaweicloud_networking_secgroup" "production-public-default" {
  name                 = "production-public-default"
  description          = "production-public-default"
  delete_default_rules = false
}

# 创建 production-private_devops 子网默认安全组
resource "huaweicloud_networking_secgroup" "production-private_devops-default" {
  name                 = "production-private_devops-default"
  description          = "production-private_devops-default"
  delete_default_rules = false
}

# 创建 production-private_db 子网默认安全组
resource "huaweicloud_networking_secgroup" "production-private_db-default" {
  name                 = "production-private_db-default"
  description          = "production-private_db-default"
  delete_default_rules = false
}

# 创建 api 网关的安全组
resource "huaweicloud_networking_secgroup" "production-public-http_gateway" {
  name                 = "production-public-http_gateway"
  description          = "production-public-http_gateway"
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
  security_group_id = huaweicloud_networking_secgroup.production-public-http_gateway.id
}

# 创建 api 网关的安全规则
resource "huaweicloud_networking_secgroup_rule" "secgroup_rule2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.production-public-http_gateway.id
}

# 创建 jumpserver 安全组
resource "huaweicloud_networking_secgroup" "production-public-jumpserver" {
  name                 = "production-public-jumpserver"
  description          = "production-public-jumpserver"
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
  security_group_id = huaweicloud_networking_secgroup.production-public-jumpserver.id
}
