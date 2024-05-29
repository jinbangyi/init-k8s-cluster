resource "null_resource" "run_ansible" {
  triggers = {
    hosts = join(",", [for instance in huaweicloud_compute_instance.prod_master : finstance.network.0.fixed_ip_v4])
  }

  provisioner "local-exec" {
    command = <<EOT
    echo ${self.access_ip_v4} > hosts.ini
    ansible-playbook --extra-vars "node_labels=['byterum.category=devops','byterum.group=http-gateway','byterum.network=private']" setup_cluster_playbook.yaml \
    --ssh-extra-args '-o ProxyCommand="ssh -p 2222 -W %h:%p -q root@${huaweicloud_vpc_eip.prod_jumpserver.address} -i ~/.ssh/ansible_rsa"'
    EOT
    working_dir = "${path.module}/../ansible"
  }

  depends_on = [ huaweicloud_compute_instance.prod_http_gateway ]
}
