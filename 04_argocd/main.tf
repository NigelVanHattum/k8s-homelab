resource "kubernetes_namespace" "argocd-namespace" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "argo"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "helm_release" "argo-cd" {
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  namespace        = kubernetes_namespace.argocd-namespace.metadata.0.name
  create_namespace = false
  name             = "argocd"
  version          = var.argo_cd_version

  values = [
    templatefile("helm-values/argo-cd-template.yaml", {
      tenant_id = var.azure_tenant_id
      client_id = var.azure_client_id
      client_secret = var.azure_client_secret
      entra_admin_group_id = var.entra_admin_group_id
    })
  ]
}

