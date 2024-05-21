# --------------------- 创建 http gateway lb ---------------
resource "huaweicloud_lb_loadbalancer" "prod_master" {
  name          = "prod_master"
  vip_subnet_id = huaweicloud_vpc_subnet.prod_private_devops.ipv4_subnet_id
}

# 创建 listener
resource "huaweicloud_lb_listener" "prod_master" {
  name            = "prod_master"
  protocol        = "TCP"
  protocol_port   = 443
  loadbalancer_id = huaweicloud_lb_loadbalancer.prod_master.id
}

# 创建 lb 对应的池子
resource "huaweicloud_lb_pool" "prod_master" {
  name        = "prod_master"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = huaweicloud_lb_listener.prod_master.id 
}

# 添加 ecs 至 lb
resource "huaweicloud_lb_member" "member_1" {
  address       = huaweicloud_compute_instance.prod_master[0].access_ip_v4
  protocol_port = 443
  weight        = 1
  pool_id       = huaweicloud_lb_pool.prod_master.id
  subnet_id     = huaweicloud_vpc_subnet.prod_private_devops.ipv4_subnet_id
}

resource "huaweicloud_lb_member" "member_2" {
  address       = huaweicloud_compute_instance.prod_master[1].access_ip_v4
  protocol_port = 443
  weight        = 1
  pool_id       = huaweicloud_lb_pool.prod_master.id
  subnet_id     = huaweicloud_vpc_subnet.prod_private_devops.ipv4_subnet_id
}

resource "huaweicloud_lb_member" "member_3" {
  address       = huaweicloud_compute_instance.prod_master[2].access_ip_v4
  protocol_port = 443
  weight        = 1
  pool_id       = huaweicloud_lb_pool.prod_master.id
  subnet_id     = huaweicloud_vpc_subnet.prod_private_devops.ipv4_subnet_id
}

# TODO 配置访问日志
