#  https://intel.github.io/intel-device-plugins-for-kubernetes/INSTALL.html
# https://taloscommunity.slack.com/archives/CG25RPZNE/p1756898418954699

module "intel_operator" {
  source = "../modules/argocd-app"

  depends_on = [
    module.cert_manager,
    argocd_project.argo-cd-system-project,
    module.nfd
    ]

  app_name ="intel-operator"
  argocd_project = argocd_project.argo-cd-system-project.metadata.0.name
  namespace = kubernetes_namespace.intel_gpu.metadata.0.name
  chart   = {
    repo_url  = "https://intel.github.io/helm-charts/"
    repo_exists = false
    chart     = "intel-device-plugins-operator"
    version   = var.intel_operator_chart_version
  }
}

module "intel_device_plugin" {
  source = "../modules/argocd-app"

  depends_on = [
    module.cert_manager,
    argocd_project.argo-cd-system-project,
    module.nfd,
    module.intel_operator
    ]

  app_name ="intel-gpu"
  argocd_project = argocd_project.argo-cd-system-project.metadata.0.name
  namespace = kubernetes_namespace.intel_gpu.metadata.0.name
  chart   = {
    repo_url  = "https://intel.github.io/helm-charts/"
    repo_exists = true
    chart     = "intel-device-plugins-gpu"
    version   = var.intel_operator_chart_version
  }
}