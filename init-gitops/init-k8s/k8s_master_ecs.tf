# master
resource "huaweicloud_compute_instance" "prod_master" {
  # TODO names from var
  name               = "prod-master-00${count.index}"
  hostname           = "prod-master-00${count.index}"
  key_pair           = var.prod_ecs_keypair
  system_disk_size   = 40
  image_id           = data.huaweicloud_images_image.default.id
  flavor_id          = data.huaweicloud_compute_flavors.prod_http_gateway.ids[0]
  availability_zone  = data.huaweicloud_availability_zones.default.names[0]
  security_group_ids = [
    huaweicloud_networking_secgroup.prod_default.id,
    huaweicloud_networking_secgroup.prod_private_devops-default.id,
  ]

  tags = {
    "env": "prod",
    "category": "devops",
    "group": "master",
  }

  network {
    uuid = huaweicloud_vpc_subnet.prod_private_devops.id
  }

  provisioner "remote-exec" {
   inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]

   connection {
      type                = "ssh"

      host                = self.access_ip_v4
      user                = "root"
      port                = 2222
      private_key         = file(pathexpand("~/.ssh/ansible_rsa"))

      bastion_host        = huaweicloud_vpc_eip.prod_jumpserver.address
    }
  }

  count = 3

  depends_on = [ huaweicloud_rds_instance.k8s_pg ]
}

# Use the IP list in local-exec
resource "null_resource" "run_ansible" {
  triggers = {
    ecs_ips = join(",", concat([huaweicloud_vpc_eip.prod_master_lb.address, var.prod_master_domain], [for instance in huaweicloud_compute_instance.prod_master : instance.network.0.fixed_ip_v4]))
    hosts = join(",", [for instance in huaweicloud_compute_instance.prod_master : format("prod-master-%s ansible_host=%s",instance.id,instance.network.0.fixed_ip_v4)])
  }

  provisioner "local-exec" {
    command = <<EOT
      # init k8s cluster
      echo '${self.triggers.hosts}' | awk 'gsub(/,/,"\n")' > hosts.ini
      echo ansible-playbook setup_cluster_playbook.yaml --extra-vars "loadbalancer_ip=${huaweicloud_lb_loadbalancer.prod_master.vip_address} \
      database_host=${huaweicloud_rds_instance.k8s_pg.private_dns_names[0]} \
      database_user=root \
      database_password=${var.postgreSQL_password} \
      database_name=kube_prod \
      database_port=5432 \
      master_ip_string=${self.triggers.ecs_ips} \
      node_labels=['byterum.category=devops','byterum.group=master','byterum.network=private']" \
      --ssh-extra-args '-o ProxyCommand="ssh -p 2222 -W %h:%p -q root@${huaweicloud_vpc_eip.prod_jumpserver.address} -i ~/.ssh/ansible_rsa"' \
      >> run.sh
    EOT
    working_dir = "${path.module}/ansible"
  }

  depends_on = [ huaweicloud_compute_instance.prod_master, null_resource.create_db_name ]
}
