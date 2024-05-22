data "huaweicloud_availability_zones" "default" {}

# gateway
data "huaweicloud_compute_flavors" "prod_http_gateway" {
  availability_zone = data.huaweicloud_availability_zones.default.names[0]
  performance_type  = "normal"
  cpu_core_count    = 1
  memory_size       = 4
}

data "huaweicloud_images_image" "default" {
  name        = "testing"
  visibility  = "private"
  most_recent = true
}

resource "huaweicloud_vpc" "prod_vpc2" {
  name = "prod_vpc2"
  cidr = "10.10.0.0/16"
}

resource "huaweicloud_vpc_subnet" "prod_public" {
  name       = "prod_public"
  cidr       = "10.10.12.0/22"
  gateway_ip = "10.10.12.1"
  vpc_id     = huaweicloud_vpc.prod_vpc2.id
  dns_list   = ["100.125.1.250", "100.125.128.250"]
}

resource "huaweicloud_networking_secgroup" "prod_public-jumpserver2" {
  name                 = "prod_public-jumpserver2"
  description          = "prod_public-jumpserver2"
  delete_default_rules = false
}

# 创建 jumpserver2 安全组规则
resource "huaweicloud_networking_secgroup_rule" "secgroup_rule3" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2222
  port_range_max    = 2222
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.prod_public-jumpserver2.id
}

# jumpserver2
resource "huaweicloud_compute_instance" "jumpserver2" {
  name               = "prod-jumpserver2-000"
  hostname           = "prod-jumpserver2-000"
  # account keypair
  key_pair           = "benny"
  system_disk_size   = 40
  image_id           = data.huaweicloud_images_image.default.id
  flavor_id          = data.huaweicloud_compute_flavors.prod_http_gateway.ids[0]
  availability_zone  = data.huaweicloud_availability_zones.default.names[0]
  security_group_ids = [
    huaweicloud_networking_secgroup.prod_public-jumpserver2.id
  ]

  network {
    uuid = huaweicloud_vpc_subnet.prod_public.id
  }
}

resource "huaweicloud_vpc_eip" "prod_jumpserver2" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "prod_jumpserver2"
    # 1-300
    size        = 50
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

resource "huaweicloud_compute_eip_associate" "associated" {
  public_ip   = huaweicloud_vpc_eip.prod_jumpserver2.address
  instance_id = huaweicloud_compute_instance.jumpserver2.id
}

terraform {
  required_providers {
    huaweicloud = {
      source = "huaweicloud/huaweicloud"
      version = ">= 1.20.0"
    }

  }
  required_version = ">= 0.13"
}

provider "huaweicloud" {
  region = "ap-southeast-3"
}
