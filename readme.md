# docs

## refer

- <https://piotrminkowski.com/2022/06/28/manage-kubernetes-cluster-with-terraform-and-argo-cd/>

## logic

- using terraform create ecs and other resource
- using ansible init ecs and add it to k8s cluster

## steps

### 1.准备初始化集群相关资源

环境变量

```bash
# 华为云 secret key
export HW_SECRET_KEY=''
# 华为云 apikey
export HW_ACCESS_KEY=''
# 华为云 rds pg 账号密码，需要符合华为云 rds 密码规则
export TF_VAR_postgreSQL_password=''
```

- ecs 机器

