# docs

## requirement

```bash
# 1. 将 keypair 对应的 pem 文件防至 ~/.ssh/ansible_rsa
chmod 400 ~/.ssh/ansible_rsa

# 华为云 secret key
export HW_SECRET_KEY='xx'
# 华为云 access key
export HW_ACCESS_KEY='xx'
# master 节点的公网域名
export TF_VAR_prod_master_domain='xx'

terraform init
terraform apply

# 需要在合适的地方添加引号
/bin/bash ansible/run.sh

# 进入 master 节点查看信息
# ssh root@{IP} -p 2222 -i ~/.ssh/ansible_rsa -o ProxyCommand="ssh -p 2222 -W %h:%p -q root@{JUMP} -i ~/.ssh/ansible_rsa"
```
