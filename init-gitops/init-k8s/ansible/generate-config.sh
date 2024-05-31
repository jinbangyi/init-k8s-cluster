TOKEN=`kubectl -n kube-system get secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}') -o jsonpath='{.data.token}' | base64 -d -w0`

echo 'apiVersion: v1
kind: Config

clusters:
- name: prod
  cluster:
    insecure-skip-tls-verify: true
    server: <REPLACE>

contexts:
- name: prod
  context:
    cluster: prod
    user: admin

current-context: prod

users:
- name: admin
  user:
    token: '$TOKEN

# cat config.yaml | base64 -w0
