# variable prod_http_gateway_labels {
#   type = list(string)
#   default = [ "byterum.category=devops", "byterum.group=http-gateway", "byterum.network=private" ]
# }

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
      bastion_host        = huaweicloud_vpc_eip.prod_jumpserver.address
    }
  }

  # init node and add node to cluster
  provisioner "local-exec" {
    # ["byterum.category=devops","byterum.group=http-gateway","byterum.network=private"]
    command = <<EOT
    echo ${self.access_ip_v4} > hosts.ini
    ansible-playbook --extra-vars "node_labels=['byterum.category=devops','byterum.group=http-gateway','byterum.network=private']" setup_cluster_playbook.yaml \
    --ssh-extra-args '-o ProxyCommand="ssh -p 2222 -W %h:%p -q root@${huaweicloud_vpc_eip.prod_jumpserver.address} -i ~/.ssh/ansible_rsa" StrictHostKeyChecking=no'
    EOT
    working_dir = "${path.module}/../ansible"
  }

  count = 2

  depends_on = [ huaweicloud_compute_instance.prod_master, null_resource.run_ansible ]
}
