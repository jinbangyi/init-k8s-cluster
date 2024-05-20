# 1. 创建 vpc
resource "huaweicloud_vpc" "vpc" {
  name = "vpc-production"
  cidr = "10.6.0.0/16"
}

# 2. 创建子网
resource "huaweicloud_vpc_subnet" "production-private" {
  name       = "production-private"
  cidr       = "10.6.8.0/22"
  gateway_ip = "10.6.8.1"
  vpc_id     = huaweicloud_vpc.vpc.id
  dns_list   = ["100.125.1.250", "100.125.128.250"]
}

resource "huaweicloud_vpc_subnet" "production-public" {
  name       = "production-public"
  cidr       = "10.6.12.0/22"
  gateway_ip = "10.6.12.1"
  vpc_id     = huaweicloud_vpc.vpc.id
  dns_list   = ["100.125.1.250", "100.125.128.250"]
}

resource "huaweicloud_vpc_subnet" "production-private_devops" {
  name       = "production-private_devops"
  cidr       = "10.6.16.0/22"
  gateway_ip = "10.6.16.1"
  vpc_id     = huaweicloud_vpc.vpc.id
  dns_list   = ["100.125.1.250", "100.125.128.250"]
}

resource "huaweicloud_vpc_subnet" "production-private_db" {
  name       = "production-private_db"
  cidr       = "10.6.20.0/22"
  gateway_ip = "10.6.20.1"
  vpc_id     = huaweicloud_vpc.vpc.id
  dns_list   = ["100.125.1.250", "100.125.128.250"]
}

# 创建安全组
resource "huaweicloud_networking_secgroup" "production-default" {
  name                 = "production-default"
  description          = "production-default"
  delete_default_rules = false
}

resource "huaweicloud_networking_secgroup" "production-private-default" {
  name                 = "production-private-default"
  description          = "production-private-default"
  delete_default_rules = false
}

resource "huaweicloud_networking_secgroup" "production-public-default" {
  name                 = "production-public-default"
  description          = "production-public-default"
  delete_default_rules = false
}

resource "huaweicloud_networking_secgroup" "production-private_devops-default" {
  name                 = "production-private_devops-default"
  description          = "production-private_devops-default"
  delete_default_rules = false
}

resource "huaweicloud_networking_secgroup" "production-private_db-default" {
  name                 = "production-private_db-default"
  description          = "production-private_db-default"
  delete_default_rules = false
}

resource "huaweicloud_networking_secgroup" "production-public-http_gateway" {
  name                 = "production-public-http_gateway"
  description          = "production-public-http_gateway"
  delete_default_rules = false
}

resource "huaweicloud_networking_secgroup_rule" "secgroup_rule1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.production-public-http_gateway.id
}

resource "huaweicloud_networking_secgroup_rule" "secgroup_rule2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.production-public-http_gateway.id
}

resource "huaweicloud_networking_secgroup" "production-public-jumpserver" {
  name                 = "production-public-jumpserver"
  description          = "production-public-jumpserver"
  delete_default_rules = false
}

resource "huaweicloud_networking_secgroup_rule" "secgroup_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2222
  port_range_max    = 2222
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.production-public-jumpserver.id
}
