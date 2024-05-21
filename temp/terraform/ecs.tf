# 可用区没有特别的要求
data "huaweicloud_availability_zones" "default" {}

# gateway
data "huaweicloud_compute_flavors" "http_gateway" {
  availability_zone = data.huaweicloud_availability_zones.default.names[0]
  performance_type  = "normal"
  cpu_core_count    = 2
  memory_size       = 4
}

data "huaweicloud_images_image" "default" {
  name        = "2C4G40G"
  visibility  = "private"
  most_recent = true
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!@#$%*"
}

resource "huaweicloud_compute_instance" "http_gateway" {
  name               = "prod-gateway-00${count.index}"
  admin_pass         = random_password.password.result
  image_id           = data.huaweicloud_images_image.default.id
  flavor_id          = data.huaweicloud_compute_flavors.http_gateway.ids[0]
  availability_zone  = data.huaweicloud_availability_zones.default.names[0]
  security_group_ids = [data.huaweicloud_networking_secgroup.mysecgroup.id]

  network {
    uuid = huaweicloud_vpc_subnet.production-private.id
  }

  count = 2
}
