resource "huaweicloud_kps_keypair" "manager-keypair" {
  name            = var.prod_ecs_keypair
  key_file        = "huawei-key.pem"
  scope           = "account"
}
