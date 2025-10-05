module "nfd" {
  source = "../modules/argocd-app"

  depends_on = [
    module.cert_manager,
    argocd_project.argo-cd-system-project
    ]

  app_name ="intel-nfd"
  argocd_project = argocd_project.argo-cd-system-project.metadata.0.name
  namespace = kubernetes_namespace.nfd.metadata.0.name
  chart   = {
    repo_url  = "registry.k8s.io/nfd/charts"
    repo_exists = false
    oci_repo  = true
    chart     = "node-feature-discovery"
    version   = var.nfd_chart_version
  }
}