# docs

## requirements

- 准备华为云账号
- 华为云账号准备好机器镜像
- 准备一台 debian 机器，用于运行脚本

- 添加 ssh private key 至 github

## steps

1. 初始化 k8s 集群

```bash
mkdir -p ~/temp/prod
cd ~/temp/prod
ROOT_DIR=`pwd`

# clone code
git clone https://github.com/jinbangyi/init-k8s-cluster.git && git checkout dev
cd init-k8s-cluster && cd init-gitops

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

# 如果出现登陆失败，尝试将生成的私钥导入华为云
# /dew/kps/kpsList/accountKey

# init k8s
cd ansible
/bin/bash run.sh
source temp.env && source token.env

# backup
sed -i "s/<REPLACE>/$MASTER_LB_IP/" config.yaml
cp config.yaml $ROOT_DIR/
echo "PG_PASSWORD=$PG_PASSWORD" >> $ROOT_DIR/README.pass

# init http gateway
cd ../../init-http-gateway

# master 节点的公网域名
# export TF_VAR_prod_k8s_token=`yq -e '.users[] | select(.name == "admin") | .user.token' $$ROOT_DIR/config.yaml`
export TF_VAR_prod_k8s_token=$SERVER_TOKEN
# ecs 镜像的名字
export TF_VAR_prod_jumpserver_ip=$JUMP_IP
export TF_VAR_prod_master_lb=$MASTER_LB_IP

terraform init
terraform apply -auto-approve

cd ansible
/bin/bash run.sh

# init devops
# TODO create ecs from vars or files
cd ../../init-devops

terraform init
terraform apply -auto-approve

cd ansible
# TODO add private registry auth
echo '
configs:
  "TODO":
    insecure_skip_verify: false
    auth:
      username: "TODO"
      password: "TODO"' > registries.yaml

/bin/bash run.sh
```

2. 初始化 gitops 基础依赖

apisix、argocd、local-storage、kube-dashboard

```bash
# login into master node from ecs
export JUMP_IP='TODO'
export MASTER_IP='TODO'

ssh root@$MASTER_IP -p 2222 -i ~/.ssh/ansible_rsa -o ProxyCommand="ssh -p 2222 -W %h:%p -q root@$JUMP_IP -i ~/.ssh/ansible_rsa -o StrictHostKeyChecking=no"

cd ~

ssh-keygen -t rsa -q -f "$HOME/.ssh/id_rsa" -N ""
# TODO add sshkey to gitops github
cat "$HOME/.ssh/id_rsa.pub"

PRIVATE_KEY=`cat "$HOME/.ssh/id_rsa" | base64 -w0`

git clone git@github.com:jinbangyi/gitops.git
cd gitops && git checkout master

cd apps/devops/argocd

# init github sshkey
echo '
apiVersion: v1
kind: Secret
metadata:
  name: ssh-key-secret
data:
  sshPrivateKey: '$PRIVATE_KEY > install/base/ssh-private-secret.yaml

export K8S_ADMIN_TOKEN='TODO'
export MASTER_LB_PUBLIC_IP='TODO'
export K8S_CA='TODO'

# init kubeconfig
echo '
apiVersion: v1
kind: Secret
metadata:
  name: cluster-prod
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  config: |
    {
      "bearerToken": "'$K8S_ADMIN_TOKEN'",
      "tlsClientConfig": {
        "caData": "'$K8S_CA'" 
      }
    }
  name: prod
  server: https://'$MASTER_LB_PUBLIC_IP > install/base/cluster-prod-secret.yaml

# push sshkey and kubeconfig to gitops
git config --global user.email "master@nftgo.io"
git add . --force && git commit -m "init kube config and sshkey" && git push

# init argocd
kubectl create namespace argocd
kubectl kustomize install | kubectl apply -f -

kubectl kustomize appprojects | kubectl apply -f -

kubectl kustomize apps | kubectl apply -f -

# TODO download argocd cli and sync the deployment

ARGO_PASSWORD=`kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d -w0`
ARGO_SERVER_IP=kubectl get service argocd-server -n argocd | grep -v CLUSTER-IP | awk '{ print $3 }'
echo $ARGO_PASSWORD

# TODO local ssh-port-forward
export JUMP_IP='TODO'
export MASTER_IP='TODO'
export ARGO_SERVER_IP='TODO'

ssh -o StrictHostKeyChecking=no -o ProxyCommand="ssh -p 2222 -W %h:%p -q root@$JUMP_IP -i ~/.ssh/ansible_rsa -o StrictHostKeyChecking=no" -L 8080:$ARGO_SERVER_IP:80 root@$MASTER_IP -p 2222 -i ~/.ssh/ansible_rsa -N -v

# TODO local, http://localhost:8080, admin:$ARGO_PASSWORD, login to argocd web ui to check and sync the deployment
```

3. 使用 gitops 初始化 k8s 基础服务

- [x] kafka-ui
- [x] airflow, ~~migrate~~
- [ ] redisinsight, TODO add nfs-client
- [x] kube-dashboard ~~fix `Http failure during parsing for https://kube-dashboard.kbenny.com/api/v1/csrftoken/login`~~
- [ ] prometheus, grafana、loki、influxdb、telegraf
- [ ] drone、harbor、npm、pypi
- [ ] byterum-biz
- [ ] helm secret

```bash

```

## TODO

- 使用 ansible 执行磁盘初始化脚本，ansible 会卡住
