resource "argocd_repository" "postgresql" {
  repo = "registry-1.docker.io"
  name = "bitnamicharts/postgresql-ha"
  enable_oci = true
  type = "helm"
  depends_on = [time_sleep.wait_for_argo]
}

resource "kubectl_manifest" "pv_postgresql_backup" {
  yaml_body          = file("manifests/backups/pv-backup.yaml")
  override_namespace = kubernetes_namespace.postgresql.metadata.0.name

  depends_on = [
    argocd_application.nfs_csi_driver
  ]
}

resource "kubectl_manifest" "pvc_postgresql_backup" {
  yaml_body          = file("manifests/backups/pvc-postgresql.yaml")
  override_namespace = kubectl_manifest.pv_postgresql_backup.override_namespace
}

resource "argocd_application" "postgresql" {
  metadata {
    name = kubernetes_namespace.postgresql.metadata.0.name
  }

  spec {
    project = argocd_project.argo-cd-system-project.metadata.0.name
    source {
      repo_url        = argocd_repository.postgresql.repo
      chart           = argocd_repository.postgresql.name
      target_revision = var.postgresql_chart_version

      helm {
        values = file("helm-values/postgresql-ha.yaml")
        parameter {
            name = "global.postgresql.existingSecret"
            value = kubernetes_secret.postgres_admin_password.metadata.0.name
        }
        parameter {
            name = "pgpool.customUsersSecret"
            value = kubernetes_secret.pgpool_users.metadata.0.name
        }
      }
    }

    sync_policy {
      automated {
        prune       = true
        self_heal   = true
        allow_empty = true
      }
      # Only available from ArgoCD 1.5.0 onwards
      sync_options = ["Validate=false"]
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

  depends_on = [kubectl_manifest.nfs_storage_class_postgresql, 
                kubernetes_secret.pgpool_users, 
                kubectl_manifest.nfs_storage_class_postgresql,
                kubectl_manifest.nfs_storage_class_backup]
}

resource "kubernetes_manifest" "postgres_ingress" {
  manifest = yamldecode(file("${path.module}/manifests/ingress/postgresql.yaml"))
  ## wait does not work, there is no status viewer for it
  # wait {
  #   rollout = true
  # }
  depends_on = [argocd_application.postgresql, argocd_application.traefik]
}

resource "time_sleep" "wait_for_postgress" {
  depends_on = [kubernetes_manifest.postgres_ingress]

  ### Postgresql is slow to start.....
  create_duration = "1m"
}