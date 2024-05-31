# docs

## requirements

- 准备华为云账号
- 华为云账号准备好机器镜像
- 准备一台 debian 机器，用于运行脚本

## steps

```bash
ROOT_DIR="~/temp/prod"
mkdir -p $ROOT_DIR && cd $ROOT_DIR

# clone code
git clone https://github.com/jinbangyi/init-k8s-cluster.git && git checkout dev
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

# generate sshkey and upload to huaweicloud
cd init-sshkey
terraform init
terraform apply -auto-approve
# 备份
mkdir -p ~/.ssh && cp huawei-key.pem ~/.ssh/ && cp huawei-key.pem $ROOT_DIR/

# ansible 执行 key
cp ~/.ssh/huawei-key.pem ~/.ssh/ansible_rsa && chmod 400 ~/.ssh/ansible_rsa

# master 节点的公网域名
export TF_VAR_prod_master_domain='TODO'
# ecs 镜像的名字
export TF_VAR_prod_ecs_image_name='TODO'

cd ../init-k8s
terraform init
terraform apply -auto-approve

/bin/bash ansible/run.sh
source ansible/temp.env

sed -i "s/<replace>/$MASTER_LB_IP/" ansible/config.yaml
cp ansible/config.yaml $ROOT_DIR/

echo "PG_PASSWORD=$PG_PASSWORD" >> $ROOT_DIR/README.pass

```
