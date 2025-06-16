resource "argocd_repository" "m3l" {
  repo = "https://helm-charts.rm3l.org"
  name = "m3l"
  type = "helm"
  depends_on = [time_sleep.wait_for_argo]
}



resource "kubernetes_secret" "adguard_bootstrap" {
  metadata {
    name      = "bootstrap"
    namespace = kubernetes_namespace.adguard.metadata.0.name 
  }

  data = {
    "AdGuardHome.yaml" = templatefile("${path.module}/config-files/AdGuardHome.yaml", {
            traefik_ip = local.ip_address.ingress
            local_domain = "local.${local.domain}"
        })
  }
}

# resource "argocd_application" "adguard" {
#   metadata {
#     name = kubernetes_namespace.adguard.metadata.0.name
#   }
#   wait = true
#   spec {
#     project = argocd_project.argo-cd-system-project.metadata.0.name
#     source {
#       repo_url        = argocd_repository.m3l.repo
#       chart           = "adguard-home"
#       target_revision = var.adguard_home_chart_version

#       helm {
#         values = templatefile("helm-values/adguard.yaml", {
#           existingSecret = kubernetes_secret.influxdb_admin.metadata.0.name
#           adminUser = data.onepassword_item.influxdb_admin_user.password
#           storageClass = "nfs-csi-influxdb"
#         })
#       }
#     }

#     sync_policy {
#       automated {
#         prune       = true
#         self_heal   = true
#         allow_empty = true
#       }
#       # Only available from ArgoCD 1.5.0 onwards
#       sync_options = ["Validate=false"]
#       retry {
#         limit = "5"
#         backoff {
#           duration     = "30s"
#           max_duration = "2m"
#           factor       = "2"
#         }
#       }
#     }

#     destination {
#       namespace = kubernetes_namespace.adguard.metadata.0.name
#       name = "in-cluster"
#     }
#   }
# }