data "huaweicloud_vpc_subnet" "prod_private" {
  name       = "prod_private"
}

# 创建 gateway lb eip
resource "huaweicloud_vpc_eip" "prod_gateway_lb" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "prod_gateway_lb"
    # 1-300
    size        = 200
    share_type  = "PER"
    charge_mode = "traffic"
  }
}
