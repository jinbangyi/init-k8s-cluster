# init

## requirement

- 华为云 access-key-id、access-secret
- http gateway、jumpserver、master ecs 镜像
- cloudflare token

## dir

- network.tf vpc, 子网, eip

## TODO

- terraform 初始化 k8s 基础资源
  - ~~所有未添加前缀的资源添加前缀~~
  - s3 最为状态存储中心
- 初始化 k8s 集群
  - 初始化一个 pg 节点给 master
