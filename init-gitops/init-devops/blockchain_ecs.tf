resource "huaweicloud_evs_volume" "blockchain_eth" {
  name              = "blockchain-eth-001"
  availability_zone = data.huaweicloud_availability_zones.default.names[0]
  volume_type       = "GPSSD"
  size              = 2000
}

resource "huaweicloud_compute_instance" "blockchain_eth" {
  name               = "blockchain-eth-001"
  hostname           = "blockchain-eth-001"
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
    "group": "infra",
  }

  network {
    uuid = data.huaweicloud_vpc_subnet.prod_private.id
  }
}

resource "huaweicloud_compute_volume_attach" "blockchain_eth_attached" {
  instance_id = huaweicloud_compute_instance.blockchain_eth.id
  volume_id   = huaweicloud_evs_volume.blockchain_eth.id
  device      = "/dev/vdb"

  provisioner "remote-exec" {
    # mount volume to /mnt/data
   inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]

   connection {
      host                = huaweicloud_compute_instance.blockchain_eth.access_ip_v4
      type                = "ssh"
      user                = "root"
      port                = 2222
      private_key         = file(pathexpand("~/.ssh/ansible_rsa"))
      bastion_host        = var.prod_jumpserver_ip
    }
  }

  depends_on = [ huaweicloud_compute_instance.blockchain_eth, huaweicloud_evs_volume.blockchain_eth ]
}

# add nodes to cluster
resource "null_resource" "blockchain_eth_run_ansible" {
  triggers = {
    hosts = join(",", [huaweicloud_compute_instance.blockchain_eth.network.0.fixed_ip_v4])
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "# add agent to  cluster" > blockchain_eth.sh
      echo "echo '${self.triggers.hosts},' | awk 'gsub(/,/,\"\\\n\")' > hosts.ini" >> blockchain_eth.sh
      echo "ansible-playbook site.yaml --extra-vars \"loadbalancer_ip=${var.prod_master_lb} \
      k3s_token=${var.prod_k8s_token} \
      extra_agent_args=' --node-label byterum.category=devops --node-label byterum.group=infra --node-label byterum.name=eth mainnet --node-label byterum.network=private --flannel-iface=eth0'\" \
      --ssh-extra-args '-o ProxyCommand=\"ssh -p 2222 -W %h:%p -q root@${var.prod_jumpserver_ip} -i ~/.ssh/ansible_rsa -o StrictHostKeyChecking=no\"' \
      " >> blockchain_eth.sh
    EOT
    working_dir = "${path.module}/ansible"
  }

  depends_on = [ huaweicloud_compute_instance.blockchain_eth ]
}
