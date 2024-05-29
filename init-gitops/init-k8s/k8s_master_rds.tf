variable "postgreSQL_password" {}

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
    password = var.postgreSQL_password
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

resource "null_resource" "create_db_name" {
  triggers = {
    # ip
    master_ip = huaweicloud_compute_instance.prod_master.0.network.0.fixed_ip_v4
  }

  provisioner "local-exec" {
    command = <<EOT
      # create database
      echo ssh root@${self.triggers.master_ip} -p 2222 -i ~/.ssh/ansible_rsa -o ProxyCommand="ssh -p 2222 -W %h:%p -q root@${huaweicloud_vpc_eip.prod_jumpserver.address} -i ~/.ssh/ansible_rsa" \
      'apt update && apt install postgresql-client -y && \
      psql "postgres://root:${var.postgreSQL_password}@${huaweicloud_rds_instance.k8s_pg.private_dns_names[0]}:5432/postgres" -c "drop database kube_prod;" ; \
      psql "postgres://root:${var.postgreSQL_password}@${huaweicloud_rds_instance.k8s_pg.private_dns_names[0]}:5432/postgres" -c "create database kube_prod;" || \
      echo exists' > run.sh
    EOT
    working_dir = "${path.module}/../ansible"
  }

  depends_on = [ huaweicloud_rds_instance.k8s_pg ]
}
