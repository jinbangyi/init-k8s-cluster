# 可用区没有特别的要求
data "huaweicloud_availability_zones" "default" {}

# gateway
data "huaweicloud_compute_flavors" "prod_http_gateway" {
  availability_zone = data.huaweicloud_availability_zones.default.names[0]
  performance_type  = "normal"
  cpu_core_count    = 1
  memory_size       = 4
}

data "huaweicloud_images_image" "default" {
  # 2C4G40G_1
  name        = var.prod_ecs_image_name
  visibility  = "private"
  most_recent = true
}

# jumpserver
resource "huaweicloud_compute_instance" "jumpserver" {
  name               = "prod-jumpserver-000"
  hostname           = "prod-jumpserver-000"
  key_pair           = var.prod_ecs_keypair
  system_disk_size   = 40
  image_id           = data.huaweicloud_images_image.default.id
  flavor_id          = data.huaweicloud_compute_flavors.prod_http_gateway.ids[0]
  availability_zone  = data.huaweicloud_availability_zones.default.names[0]
  security_group_ids = [
    huaweicloud_networking_secgroup.prod_default.id,
    huaweicloud_networking_secgroup.prod_public-default.id,
    huaweicloud_networking_secgroup.prod_public-jumpserver.id
  ]

  tags = {
    "env": "prod",
    "category": "devops",
    "group": "jumpserver",
  }

  network {
    uuid = huaweicloud_vpc_subnet.prod_public.id
  }
}

resource "huaweicloud_compute_eip_associate" "associated" {
  public_ip   = huaweicloud_vpc_eip.prod_jumpserver.address
  instance_id = huaweicloud_compute_instance.jumpserver.id
}
