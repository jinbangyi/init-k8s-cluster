resource "random_password" "prod_master_pg" {
  length           = 12
  special          = true
  override_special = "!@#%^*-_=+"
}

resource "huaweicloud_rds_instance" "k8s_pg" {
  name                = "prod-k8s_pg"
  flavor              = "rds.pg.n1.large.2"
  vpc_id              = huaweicloud_vpc.prod_vpc.id
  subnet_id           = huaweicloud_vpc_subnet.prod_private_db.id
  # 只能有一个安全组，使用默认的安全组方便连接
  security_group_id   = huaweicloud_networking_secgroup.prod_default.id
  availability_zone   = [data.huaweicloud_availability_zones.default.names[0]]

  db {
    type     = "PostgreSQL"
    version  = "14"
    password = random_password.prod_master_pg.result
  }

  volume {
    type = "CLOUDSSD"
    size = 40
  }

  backup_strategy {
    start_time = "08:00-09:00"
    keep_days  = 1
  }
}

# generate create db script
resource "null_resource" "create_db_name" {
  triggers = {
    # ip
    master_ip = huaweicloud_compute_instance.prod_master.0.network.0.fixed_ip_v4
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "# create database" > run.sh
      echo "ssh root@${self.triggers.master_ip} -p 2222 -i ~/.ssh/ansible_rsa \
      -o ProxyCommand=\"ssh -p 2222 -W %h:%p -q root@${huaweicloud_vpc_eip.prod_jumpserver.address} -i ~/.ssh/ansible_rsa -o StrictHostKeyChecking=no\" \
      'apt update && apt install postgresql-client -y && \
      psql "postgres://root:${random_password.prod_master_pg.result}@${huaweicloud_rds_instance.k8s_pg.private_dns_names[0]}:5432/postgres -c \"drop database kube_prod;\" ; \
      psql "postgres://root:${random_password.prod_master_pg.result}@${huaweicloud_rds_instance.k8s_pg.private_dns_names[0]}:5432/postgres -c \"create database kube_prod;\" || \
      echo exists'" >> run.sh
      echo "MASTER_IP=${self.triggers.master_ip}" > temp.env
      echo "MASTER_LB_IP=${huaweicloud_lb_loadbalancer.prod_master.vip_address}" >> temp.env
      echo "JUMP_IP=${huaweicloud_vpc_eip.prod_jumpserver.address}" >> temp.env
      echo "PG_PASSWORD=${random_password.prod_master_pg.result}" >> temp.env
    EOT
    working_dir = "${path.module}/ansible"
  }

  depends_on = [ huaweicloud_rds_instance.k8s_pg ]
}
