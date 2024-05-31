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

# generate sshkey
cd init-sshkey
terraform init
terraform apply

huawei-key.pem

# 华为云 secret key
export HW_SECRET_KEY=''
# 华为云 apikey
export HW_ACCESS_KEY=''

cd init-gitops/init-k8s

# 华为云 rds pg 账号密码，需要符合华为云 rds 密码规则
export TF_VAR_postgreSQL_password=''
```
