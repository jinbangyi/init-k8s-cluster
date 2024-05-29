# docs

## requirement

```bash
# 1. 将 keypair 对应的 pem 文件防至 ~/.ssh/ansible_rsa
chmod 400 ~/.ssh/ansible_rsa

# 华为云 secret key
export HW_SECRET_KEY='xx'
# 华为云 access key
export HW_ACCESS_KEY='xx'
# 需要满足华为云的 pg 账号密码规则
export TF_VAR_postgreSQL_password='xx'
# master 节点的公网域名
export TF_VAR_prod_master_domain='xx'
# 华为云密钥对名字
export TF_VAR_prod_ecs_keypair='xx'

terraform init
terraform apply

/bin/bash ansible/run.sh
```
