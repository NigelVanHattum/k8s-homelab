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

## TODO
      helm {
        values = templatefile("helm-values/postgresql-cluster.yaml", {
          s3_endpoint = data.onepassword_item.synology_c2.url
          s3_access_key = data.onepassword_item.synology_c2.username
          s3_secret_key = data.onepassword_item.synology_c2.password
          s3_bucket = "postgresql-backup"
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

  provisioner "local-exec" {
    command     = "./wait_for_pods.sh postgresql-cluster-3 ${kubernetes_namespace.postgresql.metadata.0.name}"
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
    service_name = data.kubernetes_secret.postgres_admin.data["host"]
  })
  ## wait does not work, there is no status viewer for it
  # wait {
  #   rollout = true
  # }

  depends_on = [argocd_application.postgres_cluster, 
                argocd_application.traefik]
}