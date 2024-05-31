# docs

## requirements

- 准备华为云账号
- 华为云账号准备好机器镜像
- 准备一台 debian 机器，用于运行脚本

## steps

```bash
# clone code
git clone https://github.com/jinbangyi/init-k8s-cluster.git
cd init-k8s-cluster

# download terraform
apt-get update && apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
tee /etc/apt/sources.list.d/hashicorp.list

apt update && apt-get install terraform -y

# 华为云 secret key
export HW_SECRET_KEY='TODO'
# 华为云 apikey
export HW_ACCESS_KEY='TODO'

# generate sshkey and upload to huaweiyun
cd init-sshkey
terraform init
terraform apply -auto-approve
# 备份一份
mkdir -p ~/.ssh && cp huawei-key.pem ~/.ssh/

cd ../init-k8s
# ansible 执行 key
cp huawei-key.pem ~/.ssh/ansible_rsa && chmod 400 ~/.ssh/ansible_rsa

# master 节点 pg，需要满足华为云的 pg 账号密码规则
export TF_VAR_postgreSQL_password='TODO'
# master 节点的公网域名
export TF_VAR_prod_master_domain='TODO'

terraform init
terraform apply -auto-approve


# 需要在合适的地方添加引号
/bin/bash ansible/run.sh


cd init-gitops/init-k8s

# 华为云 rds pg 账号密码，需要符合华为云 rds 密码规则
export TF_VAR_postgreSQL_password=''
```
