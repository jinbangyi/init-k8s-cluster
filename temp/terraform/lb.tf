# --------------------- 创建 http gateway lb ---------------
resource "huaweicloud_lb_loadbalancer" "http_gateway" {
  name = "http_gateway"
  vip_subnet_id = huaweicloud_vpc_subnet.production-private.ipv4_subnet_id
}

# 关联 eip 至 lb
resource "huaweicloud_vpc_eip_associate" "http_gateway" {
 public_ip = huaweicloud_vpc_eip.gateway_lb.address
 port_id  = huaweicloud_lb_loadbalancer.http_gateway.vip_port_id
}

# 创建 listener
resource "huaweicloud_lb_listener" "http_gateway" {
  protocol        = "HTTP"
  protocol_port   = 443
  loadbalancer_id = huaweicloud_lb_loadbalancer.http_gateway.id
}

# 创建 lb 对应的池子
resource "huaweicloud_lb_pool" "http_gateway" {
 protocol = "HTTP"
 lb_method = "ROUND_ROBIN"
 listener_id = huaweicloud_lb_listener.http_gateway.id 
}

# 添加 ecs 至 lb
resource "huaweicloud_lb_member" "member_1" {
  address       = huaweicloud_compute_instance.http_gateway[0].access_ip_v4
  protocol_port = 443
  weight        = 1
  pool_id       = huaweicloud_lb_pool.http_gateway.id
  subnet_id     = huaweicloud_vpc_subnet.production-private.ipv4_subnet_id
}

resource "huaweicloud_lb_member" "member_2" {
  address       = huaweicloud_compute_instance.http_gateway[1].access_ip_v4
  protocol_port = 443
  weight        = 1
  pool_id       = huaweicloud_lb_pool.http_gateway.id
  subnet_id     = huaweicloud_vpc_subnet.production-private.ipv4_subnet_id
}

# --------------------- end ---------------

# resource "huaweicloud_lb_monitor" "monitor_tcp" {
#   pool_id     = var.pool_id
#   type        = "TCP"
#   delay       = 5
#   timeout     = 3
#   max_retries = 3
# }
