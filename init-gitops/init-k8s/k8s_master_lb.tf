# --------------------- 创建 k8s master lb ---------------
resource "huaweicloud_lb_loadbalancer" "prod_master" {
  name          = "prod_master"
  vip_subnet_id = huaweicloud_vpc_subnet.prod_private_devops.ipv4_subnet_id
}

# 关联 eip 至 lb
resource "huaweicloud_vpc_eip_associate" "prod_master" {
  public_ip = huaweicloud_vpc_eip.prod_master_lb.address
  port_id   = huaweicloud_lb_loadbalancer.prod_master.vip_port_id
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
resource "huaweicloud_lb_member" "k8s_master_member_1" {
  address       = huaweicloud_compute_instance.prod_master[count.index].access_ip_v4
  protocol_port = 6443
  weight        = 1
  pool_id       = huaweicloud_lb_pool.prod_master.id
  subnet_id     = huaweicloud_vpc_subnet.prod_private_devops.ipv4_subnet_id

  count = 3
}

# TODO 配置访问日志
