data "kubernetes_secret" "argocd_secret" {
  metadata {
    name = "argocd-admin-password"
    namespace = "argo"
  }
}
