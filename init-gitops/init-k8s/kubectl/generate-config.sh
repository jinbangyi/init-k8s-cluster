TOKEN=kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')

echo 'apiVersion: v1
kind: Config

clusters:
- name: prod
  cluster:
#    server: https://localhost:6443
    insecure-skip-tls-verify: true
    server: https://10.6.18.85

contexts:
- name: prod
  context:
    cluster: prod
    user: admin

current-context: prod

users:
- name: admin
  user:
    token: '$TOKEN > config.yaml

cat config.yaml | base64 -w0
