resource "argocd_repository" "influxdb" {
  repo = "https://helm.influxdata.com"
  name = "influxdb2"
  type = "helm"
  depends_on = [time_sleep.wait_for_argo]
}

# resource "argocd_application" "influxdb" {
#   metadata {
#     name = kubernetes_namespace.influxdb.metadata.0.name
#   }
#   wait = true
#   spec {
#     project = argocd_project.argo-cd-system-project.metadata.0.name
#     source {
#       repo_url        = argocd_repository.influxdb.repo
#       chart           = argocd_repository.influxdb.name
#       target_revision = var.influxdb_chart_version

#       helm {
#         values = templatefile("helm-values/influxdb.yaml", {
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
#       namespace = kubernetes_namespace.influxdb.metadata.0.name
#       name = "in-cluster"
#     }
#   }
#   depends_on = [kubectl_manifest.nfs_storage_class_influxdb]
# }