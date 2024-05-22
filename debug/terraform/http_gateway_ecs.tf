resource "huaweicloud_compute_instance" "prod_http_gateway" {
  name               = "prod-gateway-00${count.index}"
  hostname           = "prod-gateway-00${count.index}"
  key_pair           = "benny"
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
     host        = self.access_ip_v4
     type        = "ssh"
     user        = "root"
     port        = 2222
     private_key = file(pathexpand("~/.ssh/ansible_rsa"))
    }
  }

  provisioner "local-exec" {
    command = <<EOT
      do-ansible-inventory --group-by-tag > hosts.ini
      ansible-playbook setup_cluster_playbook.yaml -u root --private-key ~/.ssh/ansible_rsa
    EOT
    working_dir = "${path.module}/../ansible"
  }

  count = 2
}