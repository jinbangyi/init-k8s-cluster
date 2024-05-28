resource "huaweicloud_evs_volume" "prod_devops" {
  name              = "prod-devops-00${count.index}"
  availability_zone = data.huaweicloud_availability_zones.default.names[0]
  volume_type       = "SAS"
  size              = 300

  count = 1
}

resource "huaweicloud_compute_instance" "prod_devops" {
  name               = "prod-devops-00${count.index}"
  hostname           = "prod-devops-00${count.index}"
  key_pair           = "aws-manager"
  system_disk_size   = 40
  image_id           = data.huaweicloud_images_image.default.id
  flavor_id          = data.huaweicloud_compute_flavors.prod_devops.ids[0]
  availability_zone  = data.huaweicloud_availability_zones.default.names[0]
  security_group_ids = [
    huaweicloud_networking_secgroup.prod_default.id,
    huaweicloud_networking_secgroup.prod_private-default.id
  ]

  tags = {
    "env": "prod",
    "category": "devops",
    "group": "management",
  }

  network {
    uuid = huaweicloud_vpc_subnet.prod_private.id
  }

  provisioner "local-exec" {
    command = <<EOT
    echo ${self.access_ip_v4} > hosts.ini
    ansible-playbook --extra-vars "node_labels=['byterum.category=devops','byterum.group=management','byterum.network=private']" setup_cluster_playbook.yaml
    EOT
    working_dir = "${path.module}/../ansible"
  }

  count = 1
}

resource "huaweicloud_compute_volume_attach" "attached" {
  instance_id = huaweicloud_compute_instance.prod_devops.0.id
  volume_id   = huaweicloud_evs_volume.prod_devops.0.id

  provisioner "remote-exec" {
    # mount volume to /mnt/data
   inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]

   connection {
      host                = huaweicloud_compute_instance.prod_devops.0.access_ip_v4
      type                = "ssh"
      user                = "root"
      port                = 2222
      private_key         = file(pathexpand("~/.ssh/ansible_rsa"))
      bastion_host        = huaweicloud_vpc_eip.prod_jumpserver.address
    }
  }

  depends_on = [ huaweicloud_compute_instance.prod_devops, huaweicloud_evs_volume.prod_devops ]
}
