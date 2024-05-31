# install argocd
resource "helm_release" "argocd" {
  chart            = "argo-cd"
  name             = "argocd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  create_namespace = true
}

# config gitops
# apiVersion: argoproj.io/v1alpha1
# kind: AppProject
# metadata:
#   name: devops
#   namespace: argo-cd
# spec:
#   clusterResourceWhitelist:
#     - group: '*'
#       kind: '*'
#   destinations:
#     - name: '*'
#       namespace: '*'
#       server: '*'
#   namespaceResourceWhitelist:
#     - group: '*'
#       kind: '*'
#   sourceRepos:
#     - '*'
