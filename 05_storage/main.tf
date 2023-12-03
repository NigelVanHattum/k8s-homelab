resource "kubernetes_namespace" "nfs-csi-driver" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "nfs-csi-driver"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "argocd_repository" "nfs-csi-driver" {
  repo = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts"
  name = "csi-driver-nfs"
  type = "helm"
}

resource "argocd_application" "nfs-csi-driver" {
  metadata {
    name = kubernetes_namespace.nfs-csi-driver.metadata.0.name
  }

  spec {
    project = "system"
    source {
      repo_url        = argocd_repository.nfs-csi-driver.repo
      chart           = argocd_repository.nfs-csi-driver.name
      target_revision = var.nfs_csi_driver_version
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
      namespace = kubernetes_namespace.nfs-csi-driver.metadata.0.name
      name = "in-cluster"
    }
  }
}

resource "kubectl_manifest" "nfs-storage-class-postgresql" {
  yaml_body          = file("manifests/nfs-storageClass-postgresql.yaml")
  override_namespace = kubernetes_namespace.nfs-csi-driver.metadata.0.name

  depends_on = [
    kubernetes_namespace.nfs-csi-driver,
    argocd_application.nfs-csi-driver,
  ]
}

resource "kubectl_manifest" "nfs-storage-class-traefik" {
  yaml_body          = file("manifests/nfs-storageClass-traefik.yaml")
  override_namespace = kubernetes_namespace.nfs-csi-driver.metadata.0.name

  depends_on = [
    kubernetes_namespace.nfs-csi-driver,
    argocd_application.nfs-csi-driver,
  ]
}

resource "kubectl_manifest" "nfs-storage-class-authentik" {
  yaml_body          = file("manifests/nfs-storageClass-authentik.yaml")
  override_namespace = kubernetes_namespace.nfs-csi-driver.metadata.0.name

  depends_on = [
    kubernetes_namespace.nfs-csi-driver,
    argocd_application.nfs-csi-driver,
  ]
}