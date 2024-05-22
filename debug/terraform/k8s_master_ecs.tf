# master
resource "huaweicloud_compute_instance" "prod_master" {
  name               = "prod-master-00${count.index}"
  hostname           = "prod-master-00${count.index}"
  key_pair           = "benny"
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
     host        = self.access_ip_v4
     type        = "ssh"
     user        = "root"
     port        = 2222
     private_key = file(pathexpand("~/.ssh/ansible_rsa"))
    }
  }

  # provisioner "local-exec" {
  #   working_dir = "${path.module}/../ansible"
  #   command = <<-EOF
  #   do-ansible-inventory --group-by-tag > hosts.ini
  #   ansible-playbook setup_cluster_playbook.yaml -u root --private-key ~/.ssh/ansible_rsa --extra-vars "loadbalancer_ip=${huaweicloud_lb_loadbalancer.prod_master.vip_port_id} database_host=${digitalocean_database_cluster.postgres.host} database_user=admin database_password=${digitalocean_database_user.dbuser.password} database_name=${digitalocean_database_cluster.postgres.database} database_port=${digitalocean_database_cluster.postgres.port} master_ip_string=${master_ip_string.default}"
  # EOF
  # }

  count = 3

  depends_on = [ huaweicloud_rds_instance.k8s_pg ]
}

# # Generate a comma-separated string of IP addresses
# variable "master_ip_string" {
#   value = join(",", [for instance in huaweicloud_compute_instance.prod_master : instance.network.0.fixed_ip_v4])
# }

output master_value {
  # Ids for multiple sets of EC2 instances, merged together
  value = join(",", [for instance in huaweicloud_compute_instance.prod_master : instance.network.0.fixed_ip_v4])
}

# Use the IP list in local-exec
resource "null_resource" "run_ansible" {
  triggers = {
    ecs_ips = join(",", [for instance in huaweicloud_compute_instance.prod_master : instance.network.0.fixed_ip_v4])
  }

  provisioner "local-exec" {
    command = <<EOT
      do-ansible-inventory --group-by-tag > hosts.ini
      ansible-playbook setup_cluster_playbook.yaml -u root --private-key ~/.ssh/ansible_rsa \
      --extra-vars "loadbalancer_ip=${huaweicloud_lb_loadbalancer.prod_master.vip_port_id} \
      database_host=${huaweicloud_rds_instance.k8s_pg.private_dns_names[0]} \
      database_user=root \
      database_password=${var.postgreSQL_password} \
      database_name=kube_prod \
      database_port=5432 \
      master_ip_string=${self.triggers.ecs_ips}"
    EOT
    working_dir = "${path.module}/../ansible"
  }

  depends_on = [ huaweicloud_compute_instance.prod_master ]
}
