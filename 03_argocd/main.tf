resource "helm_release" "argo-cd" {
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  namespace        = "argo"
  create_namespace = true
  name             = "argocd"
  version          = var.argo_cd_version

  values = [
    file("helm-values/argo-cd.yaml")
  ]
}

