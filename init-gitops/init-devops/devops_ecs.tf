# 可用区没有特别的要求
data "huaweicloud_availability_zones" "default" {}

# gateway
data "huaweicloud_compute_flavors" "prod_devops" {
  availability_zone = data.huaweicloud_availability_zones.default.names[0]
  performance_type  = "normal"
  cpu_core_count    = 4
  memory_size       = 32
}

data "huaweicloud_images_image" "default" {
  # 2C4G40G_1
  name        = "Debian11-40G3"
  visibility  = "private"
  most_recent = true
}

resource "huaweicloud_evs_volume" "prod_devops" {
  name              = "prod-devops-00${count.index}"
  availability_zone = data.huaweicloud_availability_zones.default.names[0]
  volume_type       = "GPSSD"
  size              = 300

  count = 1
}

resource "huaweicloud_compute_instance" "prod_devops" {
  name               = "prod-devops-00${count.index}"
  hostname           = "prod-devops-00${count.index}"
  key_pair           = var.prod_ecs_keypair
  system_disk_size   = 40
  image_id           = data.huaweicloud_images_image.default.id
  flavor_id          = data.huaweicloud_compute_flavors.prod_devops.ids[0]
  availability_zone  = data.huaweicloud_availability_zones.default.names[0]
  security_group_ids = [
    data.huaweicloud_networking_secgroup.prod_default.id,
    data.huaweicloud_networking_secgroup.prod_private-default.id
  ]

  tags = {
    "env": "prod",
    "category": "devops",
    "group": "management",
  }

  network {
    uuid = data.huaweicloud_vpc_subnet.prod_private.id
  }

  count = 1
}

resource "huaweicloud_compute_volume_attach" "attached" {
  instance_id = huaweicloud_compute_instance.prod_devops[count.index].id
  volume_id   = huaweicloud_evs_volume.prod_devops[count.index].id

  provisioner "remote-exec" {
    # mount volume to /mnt/data
   inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]

   connection {
      host                = huaweicloud_compute_instance.prod_devops[count.index].access_ip_v4
      type                = "ssh"
      user                = "root"
      port                = 2222
      private_key         = file(pathexpand("~/.ssh/ansible_rsa"))
      bastion_host        = huaweicloud_vpc_eip.prod_jumpserver.address
    }
  }

  count = 1

  depends_on = [ huaweicloud_compute_instance.prod_devops, huaweicloud_evs_volume.prod_devops ]
}

# add nodes to cluster
resource "null_resource" "run_ansible" {
  triggers = {
    hosts = join(",", [for instance in huaweicloud_compute_instance.prod_http_gateway : instance.network.0.fixed_ip_v4])
  }

  provisioner "local-exec" {
    command = <<EOT
      X='"'"'
      echo '# add agent to  cluster \
      echo "${self.triggers.hosts}" | awk $Xgsub(/,/,"\n")$X > hosts.ini
      echo ansible-playbook setup_cluster_playbook.yaml --extra-vars "loadbalancer_ip=${var.prod_master_lb} \
      k3s_token=${var.prod_k8s_token} \
      extra_agent_args=' --node-label byterum.category=devops --node-label byterum.group=http-gateway --node-label byterum.network=private --flannel-iface=eth0'" \
      --ssh-extra-args $X-o ProxyCommand="ssh -p 2222 -W %h:%p -q root@${var.prod_jumpserver_ip} -i ~/.ssh/ansible_rsa -o StrictHostKeyChecking=no"$X \
      >> run.sh
    EOT
    working_dir = "${path.module}/ansible"
  }

  depends_on = [ huaweicloud_compute_instance.prod_devops ]
}
