resource "kubernetes_namespace" "postgresql" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "postgresql"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "kubernetes_secret" "postgres_admin_password" {
  metadata {
    name = "postgres-admin-password"
    namespace = kubernetes_namespace.postgresql.metadata.0.name
  }

  immutable = true

  data = {
    repmgr-password = var.postgresql_admin_password
    password = var.postgresql_admin_password
  }
}

resource "argocd_repository" "postgresql" {
  repo = "registry-1.docker.io"
  name = "bitnamicharts/postgresql-ha"
  enable_oci = true
  type = "helm"
}

resource "argocd_application" "postgresql" {
  metadata {
    name = kubernetes_namespace.postgresql.metadata.0.name
  }

  spec {
    project = "system"
    source {
      repo_url        = argocd_repository.postgresql.repo
      chart           = argocd_repository.postgresql.name
      target_revision = var.postgresql_chart_version

      helm {
        parameter {
            name = "global.storageClass"
            value = "nfs-csi-postgresql"
        }  
        parameter {
            name = "global.postgresql.existingSecret"
            value = kubernetes_secret.postgres_admin_password.metadata.0.name
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
}