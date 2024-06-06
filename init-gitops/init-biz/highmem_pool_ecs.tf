# 可用区没有特别的要求
data "huaweicloud_availability_zones" "default" {}

# gateway
data "huaweicloud_compute_flavors" "prod_pool" {
  availability_zone = data.huaweicloud_availability_zones.default.names[0]
  performance_type  = "highmem"
  cpu_core_count    = 8
  memory_size       = 64
}

data "huaweicloud_images_image" "default" {
  # 2C4G40G_1
  name        = var.prod_ecs_image_name
  visibility  = "private"
  most_recent = true
}

resource "huaweicloud_compute_instance" "prod_pool" {
  name               = "prod-pool-00${count.index}"
  hostname           = "prod-pool-00${count.index}"
  key_pair           = var.prod_ecs_keypair
  system_disk_size   = 40
  image_id           = data.huaweicloud_images_image.default.id
  flavor_id          = data.huaweicloud_compute_flavors.prod_pool.ids[0]
  availability_zone  = data.huaweicloud_availability_zones.default.names[0]
  security_group_ids = [
    data.huaweicloud_networking_secgroup.prod_default.id,
    data.huaweicloud_networking_secgroup.prod_private-default.id
  ]

  tags = {
    "env": "prod",
    "category": "biz",
    "group": "highmem",
  }

  network {
    uuid = data.huaweicloud_vpc_subnet.prod_private.id
  }

  count = 5
}

# add nodes to cluster
resource "null_resource" "run_ansible2" {
  triggers = {
    hosts = join(",", [for instance in huaweicloud_compute_instance.prod_pool : instance.network.0.fixed_ip_v4])
    labels = "--node-label byterum.category=biz --node-label byterum.group=highmem --node-label byterum.network=private"
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "# add agent to  cluster" > run.sh
      echo "echo '${self.triggers.hosts},' | awk 'gsub(/,/,\"\\\n\")' > hosts.ini" >> run.sh
      echo "ansible-playbook site.yaml --extra-vars \"loadbalancer_ip=${var.prod_master_lb} \
      k3s_token=${var.prod_k8s_token} \
      extra_agent_args=' ${self.triggers.labels} --flannel-iface=eth0'\" \
      --ssh-extra-args '-o ProxyCommand=\"ssh -p 2222 -W %h:%p -q root@${var.prod_jumpserver_ip} -i ~/.ssh/ansible_rsa -o StrictHostKeyChecking=no\"' \
      " >> run.sh
    EOT
    working_dir = "${path.module}/ansible"
  }

  depends_on = [ huaweicloud_compute_instance.prod_pool ]
}
