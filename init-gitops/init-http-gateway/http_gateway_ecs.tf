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
  key_pair           = var.prod_ecs_keypair
  system_disk_size   = 40
  image_id           = data.huaweicloud_images_image.default.id
  flavor_id          = data.huaweicloud_compute_flavors.prod_http_gateway.ids[0]
  availability_zone  = data.huaweicloud_availability_zones.default.names[0]
  security_group_ids = [
    data.huaweicloud_networking_secgroup.prod_default.id,
    data.huaweicloud_networking_secgroup.prod_private-default.id,
    huaweicloud_networking_secgroup.prod_private-http_gateway.id,
  ]

  tags = {
    "env": "prod",
    "category": "devops",
    "group": "http-gateway",
  }

  network {
    uuid = data.huaweicloud_vpc_subnet.prod_private.id
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

# add nodes to cluster
resource "null_resource" "run_ansible" {
  triggers = {
    hosts = join(",", [for instance in huaweicloud_compute_instance.prod_http_gateway : instance.network.0.fixed_ip_v4])
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "# add agent to  cluster \
      echo '${self.triggers.hosts}' | awk 'gsub(/,/,"\n")' > hosts.ini
      echo ansible-playbook setup_cluster_playbook.yaml --extra-vars \"loadbalancer_ip=${var.prod_master_lb} \
      k3s_token=${var.prod_k8s_token} \
      extra_agent_args=' --node-label byterum.category=devops --node-label byterum.group=http-gateway --node-label byterum.network=private --flannel-iface=eth0'\" \
      --ssh-extra-args '-o ProxyCommand=\"ssh -p 2222 -W %h:%p -q root@${var.prod_jumpserver_ip} -i ~/.ssh/ansible_rsa -o StrictHostKeyChecking=no\"' \
      " > run.sh
    EOT
    working_dir = "${path.module}/ansible"
  }

  depends_on = [ huaweicloud_compute_instance.prod_http_gateway ]
}
