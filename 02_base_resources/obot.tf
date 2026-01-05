module "obot" {
  source = "../modules/argocd-app"

  depends_on = [
    argocd_project.argo-cd-system-project
    ]

  app_name ="obot"
  argocd_project = argocd_project.argo-cd-system-project.metadata.0.name
  namespace = kubernetes_namespace.obot.metadata.0.name
  chart   = {
    repo_url  = "https://charts.obot.ai"
    repo_exists = false
    chart     = "obot"
    version   = "${var.obot_chart_version}"
  }

  helm_values = templatefile("helm-values/obot.yaml",
        {
          obot_version = "${var.obot_chart_version}"
          database_dsn = "postgresql://${data.onepassword_item.database_obot.username}:${data.onepassword_item.database_obot.password}@${data.onepassword_item.database_obot.hostname}:5432/${postgresql_database.obot.name}?sslmode=disable"
        })
}
