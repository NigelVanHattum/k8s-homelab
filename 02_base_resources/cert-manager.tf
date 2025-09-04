module "cert_manager" {
  source = "../modules/argocd-app"

  app_name ="cert-manager"
  argocd_project = argocd_project.argo-cd-system-project.metadata.0.name
  namespace = kubernetes_namespace.cert_manager.metadata.0.name
  chart   = {
    repo_url  = "https://charts.jetstack.io"
    repo_exists = false
    chart     = "cert-manager"
    version   = var.cert_manager_chart_version
  }

  helm_values = file("helm-values/cert-manager.yaml")
}