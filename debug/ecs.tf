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

resource "huaweicloud_compute_instance" "http_gateway" {
  name               = "prod-gateway-00${count.index}"
  key_pair           = "manager"
  system_disk_size   = 40
  image_id           = data.huaweicloud_images_image.default.id
  flavor_id          = data.huaweicloud_compute_flavors.http_gateway.ids[0]
  availability_zone  = data.huaweicloud_availability_zones.default.names[0]
  security_group_ids = [huaweicloud_networking_secgroup.production-default.id,huaweicloud_networking_secgroup.production-private-default.id]

  network {
    uuid = huaweicloud_vpc_subnet.production-private.id
  }

  count = 2
}

resource "huaweicloud_compute_instance" "jumpserver" {
  name               = "prod-jumpserver-00${count.index}"
  key_pair           = "manager"
  system_disk_size   = 40
  image_id           = data.huaweicloud_images_image.default.id
  flavor_id          = data.huaweicloud_compute_flavors.http_gateway.ids[0]
  availability_zone  = data.huaweicloud_availability_zones.default.names[0]
  security_group_ids = [huaweicloud_networking_secgroup.production-default.id,huaweicloud_networking_secgroup.production-public-default.id]

  network {
    uuid = huaweicloud_vpc_subnet.production-public.id
  }

  count = 1
}

resource "huaweicloud_compute_eip_associate" "associated" {
  public_ip   = huaweicloud_vpc_eip.jumpserver.address
  instance_id = huaweicloud_compute_instance.jumpserver.id
}
