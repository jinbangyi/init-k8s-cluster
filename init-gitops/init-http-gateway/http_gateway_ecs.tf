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
  name        = "Debian11-40G3"
  visibility  = "private"
  most_recent = true
}

resource "huaweicloud_compute_instance" "prod_http_gateway" {
  name               = "prod-gateway-00${count.index}"
  hostname           = "prod-gateway-00${count.index}"
  key_pair           = "aws-manager"
  system_disk_size   = 40
  image_id           = data.huaweicloud_images_image.default.id
  flavor_id          = data.huaweicloud_compute_flavors.prod_http_gateway.ids[0]
  availability_zone  = data.huaweicloud_availability_zones.default.names[0]
  security_group_ids = [
    huaweicloud_networking_secgroup.prod_default.id,
    huaweicloud_networking_secgroup.prod_private-default.id,
    huaweicloud_networking_secgroup.prod_private-http_gateway.id,
  ]

  tags = {
    "env": "prod",
    "category": "devops",
    "group": "http-gateway",
  }

  network {
    uuid = huaweicloud_vpc_subnet.prod_private.id
  }

  provisioner "remote-exec" {
   inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]

   connection {
      host                = self.access_ip_v4
      type                = "ssh"
      user                = "root"
      port                = 2222
      private_key         = file(pathexpand("~/.ssh/ansible_rsa"))
      bastion_host        = var.prod_jumpserver_ip
    }
  }

  count = 2
}
