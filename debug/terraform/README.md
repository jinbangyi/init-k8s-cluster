# init

## requirement

1. init k8s
   - 华为云 access-key-id、access-secret
   - export TF_VAR_postgreSQL_password={k8s master pg 密码} (需要符合华为云的密码规则)
   - http gateway、jumpserver、master ecs 镜像
   - ~~cloudflare token~~
   - 执行 terraform 的机器上有连接新创建 ecs 的 ssh-private-key，位于 ~/.ssh/ansible.rsa
2. init resource
3. init gitops
4. init cicd
5. init infra
6. init biz

## dir

- network.tf vpc, 子网, eip

## TODO

- terraform 初始化 k8s 基础资源
  - ~~所有未添加前缀的资源添加前缀~~
  - s3 作为状态存储中心
  - ~~创建一个 ecs 用于执行 ansible 命令~~
- 初始化 k8s 集群
  - ~~初始化一个 pg 节点给 master~~
  - ~~使用 ansible 初始化 k3s~~
  - 给节点添加合适的 label
  - 添加 devops 节点
  - 创建 apisix
  - 创建 argocd

## list

- http gateway*2
- k8s master*2
- jumpserver*1
- gitops*3
  - gitlab
  - argo
  - terraform
