# 1. 创建 vpc
resource "huaweicloud_vpc" "prod_vpc" {
  name = "prod_vpc"
  cidr = "10.6.0.0/16"
}

# 创建 eip
# 创建默认 nat 出网 eip
resource "huaweicloud_vpc_eip" "prod_nat" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "prod_nat"
    # 1-300
    size        = 200
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

# 创建 master lb eip
resource "huaweicloud_vpc_eip" "prod_master_lb" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "prod_master_lb"
    # 1-300
    size        = 200
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

# 创建 jumpserver eip
resource "huaweicloud_vpc_eip" "prod_jumpserver" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "prod_jumpserver"
    # 1-300
    size        = 50
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

# 创建子网
# 创建走 nat 的子网
resource "huaweicloud_vpc_subnet" "prod_private" {
  name       = "prod_private"
  cidr       = "10.6.8.0/22"
  gateway_ip = "10.6.8.1"
  vpc_id     = huaweicloud_vpc.prod_vpc.id
  dns_list   = ["100.125.1.250", "100.125.128.250"]
}

# 创建有独立公网 IP 的子网
resource "huaweicloud_vpc_subnet" "prod_public" {
  name       = "prod_public"
  cidr       = "10.6.12.0/22"
  gateway_ip = "10.6.12.1"
  vpc_id     = huaweicloud_vpc.prod_vpc.id
  dns_list   = ["100.125.1.250", "100.125.128.250"]
}

# 创建走 nat 并且非业务、非数据库，可用性要求较低的服务
resource "huaweicloud_vpc_subnet" "prod_private_devops" {
  name       = "prod_private_devops"
  cidr       = "10.6.16.0/22"
  gateway_ip = "10.6.16.1"
  vpc_id     = huaweicloud_vpc.prod_vpc.id
  dns_list   = ["100.125.1.250", "100.125.128.250"]
}

# 创建走 nat 并且是数据库等可用性要求较高的服务
resource "huaweicloud_vpc_subnet" "prod_private_db" {
  name       = "prod_private_db"
  cidr       = "10.6.20.0/22"
  gateway_ip = "10.6.20.1"
  vpc_id     = huaweicloud_vpc.prod_vpc.id
  dns_list   = ["100.125.1.250", "100.125.128.250"]
}

# 创建 nat 并关联子网
resource "huaweicloud_nat_gateway" "prod_default" {
  name        = "prod_default"
  description = "prod_default"
  spec        = "2"
  vpc_id      = huaweicloud_vpc.prod_vpc.id
  subnet_id   = huaweicloud_vpc_subnet.prod_private.id
}

# 绑定 nat、eip、子网
resource "huaweicloud_nat_snat_rule" "rule1" {
  floating_ip_id = huaweicloud_vpc_eip.prod_nat.id
  nat_gateway_id = huaweicloud_nat_gateway.prod_default.id
  subnet_id     = huaweicloud_vpc_subnet.prod_private.id
}

resource "huaweicloud_nat_snat_rule" "rule2" {
  floating_ip_id = huaweicloud_vpc_eip.prod_nat.id
  nat_gateway_id = huaweicloud_nat_gateway.prod_default.id
  subnet_id     = huaweicloud_vpc_subnet.prod_private_devops.id
}

resource "huaweicloud_nat_snat_rule" "rule3" {
  floating_ip_id = huaweicloud_vpc_eip.prod_nat.id
  nat_gateway_id = huaweicloud_nat_gateway.prod_default.id
  subnet_id     = huaweicloud_vpc_subnet.prod_private_db.id
}
