variable "postgreSQL_password" {}

variable "availability_zone" {
  type    = string
  default = "docker-desktop"
}

resource "huaweicloud_rds_instance" "k8s_pg" {
  name                = "k8s_pg"
  flavor              = "rds.pg.n1.large.2"
  ha_replication_mode = "async"
  vpc_id              = huaweicloud_vpc.prod_vpc.id
  subnet_id           = huaweicloud_vpc_subnet.prod_private_db.id
  security_group_id   = huaweicloud_networking_secgroup.prod_private_db-default.id
  availability_zone = [var.availability_zone]

  db {
    type     = "PostgreSQL"
    version  = "14"
    password = var.postgreSQL_password
  }

  volume {
    type = "ULTRAHIGH"
    size = 40
  }

  backup_strategy {
    start_time = "08:00-14:00"
    keep_days  = 1
  }
}
