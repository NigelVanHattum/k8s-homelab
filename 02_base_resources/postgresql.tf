resource "argocd_repository" "postgresql" {
  repo = "https://cloudnative-pg.github.io/charts"
  name = "CNPG/postgres"
  type = "helm"
  depends_on = [time_sleep.wait_for_argo]
}

resource "argocd_application" "postgres_operator" {
  metadata {
    name = "${kubernetes_namespace.postgresql.metadata.0.name}-operator"
  }
  wait = true
  spec {
    project = argocd_project.argo-cd-system-project.metadata.0.name
    source {
      repo_url        = argocd_repository.postgresql.repo
      chart           = "cloudnative-pg"
      target_revision = var.cnpg_postgres_operator_chart_version
    }

    sync_policy {
      automated {
        prune       = true
        self_heal   = true
        allow_empty = true
      }
      # Only available from ArgoCD 1.5.0 onwards
      sync_options = ["Validate=false"]#, "ServerSideApply=true"]
      retry {
        limit = "5"
        backoff {
          duration     = "30s"
          max_duration = "2m"
          factor       = "2"
        }
      }
    }

    destination {
      namespace = kubernetes_namespace.postgresql.metadata.0.name
      name = "in-cluster"
    }
  }

  depends_on = [
    kubectl_manifest.nfs_storage_class_postgresql
  ]
}

resource "argocd_application" "postgres_cluster" {
  metadata {
    name = "${kubernetes_namespace.postgresql.metadata.0.name}-cluster"
  }
  wait = true

  spec {
    project = argocd_project.argo-cd-system-project.metadata.0.name
    source {
      repo_url        = argocd_repository.postgresql.repo
      chart           = "cluster"
      target_revision = var.cnpg_postgres_cluster_chart_version

      helm {
        values = templatefile("helm-values/postgresql-cluster.yaml", {
          s3_endpoint = data.onepassword_item.synology_c2.url
          s3_access_key = data.onepassword_item.synology_c2.username
          s3_secret_key = data.onepassword_item.synology_c2.password
          s3_bucket = local.database.backup_c2_bucket
          superuser_secret = kubernetes_secret.postgres_admin.metadata.0.name
        })
      }
    }

    sync_policy {
      automated {
        prune       = true
        self_heal   = true
        allow_empty = true
      }
      # Only available from ArgoCD 1.5.0 onwards
      # sync_options = ["Validate=false"] #, "ServerSideApply=true"]
      retry {
        limit = "5"
        backoff {
          duration     = "30s"
          max_duration = "2m"
          factor       = "2"
        }
      }
    }

    destination {
      namespace = kubernetes_namespace.postgresql.metadata.0.name
      name = "in-cluster"
    }
  }

  provisioner "local-exec" {
    command     = "./wait_for_pods.sh postgresql-cluster-postgresql-main-3 ${kubernetes_namespace.postgresql.metadata.0.name}"
    interpreter = ["/bin/sh", "-c"]
  }

  depends_on = [
    kubectl_manifest.nfs_storage_class_postgresql,
    argocd_application.postgres_operator
  ]
}

resource "kubectl_manifest" "postgres_ingress" {
  validate_schema = false
  yaml_body = templatefile("${path.module}/manifests/ingress/postgresql.yaml", {
    service_name = kubernetes_secret.postgres_admin.data["host"]
  })
  ## wait does not work, there is no status viewer for it
  # wait {
  #   rollout = true
  # }
}


### 
## Recovery cluster! Enable when needed
###
# resource "kubernetes_secret" "recovery_c2_credentials" {
#   metadata {
#     name = "synology-c2-credentials"
#     namespace = kubernetes_namespace.postgresql_recovery.metadata.0.name
#     labels = {
#       "cnpg.io/reload" = ""
#     }
#   }

#   data = {
#     access_key = data.onepassword_item.synology_c2.username
#     secret_key = data.onepassword_item.synology_c2.password
#   }
# }


# resource "kubernetes_secret" "postgres_admin_recovery" {
#   metadata {
#     name = "postgresql-superuser"
#     namespace = kubernetes_namespace.postgresql_recovery.metadata.0.name
#     labels = {
#       "cnpg.io/reload" = ""
#     }
#   }

#   data = {
#     username = data.onepassword_item.database_postgresql.username
#     password = data.onepassword_item.database_postgresql.password
#     host     = local.database.read_write_service_name
#   }

#   type = "kubernetes.io/basic-auth"
# }

# resource "kubectl_manifest" "postgres_recovery_ingress" {
#   validate_schema = false
#   override_namespace = kubernetes_namespace.postgresql_recovery.metadata.0.name
#   yaml_body = templatefile("${path.module}/manifests/ingress/postgresql-recovery.yaml", {
#     service_name = "cluster-restore-r"
#   })
#   ## wait does not work, there is no status viewer for it
#   # wait {
#   #   rollout = true
#   # }

#   depends_on = [ argocd_application.traefik]
# }

# resource "kubectl_manifest" "recovery_cluster" {
#   # validate_schema = false
#   override_namespace = kubernetes_namespace.postgresql_recovery.metadata.0.name
#   yaml_body = templatefile("${path.module}/manifests/postgresql-cluster-restore.yaml", {
#     superuser_secret = kubernetes_secret.postgres_admin_recovery.metadata.0.name
#     synology_c2_endpoint = data.onepassword_item.synology_c2.url
#     bucket_name = local.database.backup_c2_bucket
#     synology_c2_secret = kubernetes_secret.recovery_c2_credentials.metadata.0.name
#   })
#   ## wait does not work, there is no status viewer for it
#   # wait {
#   #   rollout = true
#   # }

#   depends_on = [ argocd_application.postgres_operator,
#                   kubectl_manifest.postgres_recovery_ingress ]
# }