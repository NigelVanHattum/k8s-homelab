resource "argocd_repository" "nfs_csi_driver" {
  repo = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts"
  name = "csi-driver-nfs"
  type = "helm"
  depends_on = [time_sleep.wait_for_argo]
}

resource "argocd_application" "nfs_csi_driver" {
  metadata {
    name = kubernetes_namespace.nfs_csi_driver.metadata.0.name
  }

  spec {
    project = argocd_project.argo-cd-system-project.metadata.0.name
    source {
      repo_url        = argocd_repository.nfs_csi_driver.repo
      chart           = argocd_repository.nfs_csi_driver.name
      target_revision = var.nfs_csi_driver_chart_version
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
      namespace = kubernetes_namespace.nfs_csi_driver.metadata.0.name
      name = "in-cluster"
    }
  }
}

resource "kubectl_manifest" "nfs_storage_class_postgresql" {
  yaml_body          = templatefile("manifests/nfs-csi/nfs-storageClass-postgresql.yaml", {
    nas_ip = local.ip_address.nas_ip
    root_path = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.nfs_csi_driver.metadata.0.name

  depends_on = [
    argocd_application.nfs_csi_driver
  ]
}

resource "kubectl_manifest" "nfs_storage_class_traefik" {
  yaml_body          = templatefile("manifests/nfs-csi/nfs-storageClass-traefik.yaml", {
    nas_ip = local.ip_address.nas_ip
    root_path = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.nfs_csi_driver.metadata.0.name

  depends_on = [
    argocd_application.nfs_csi_driver
  ]
}

resource "kubectl_manifest" "nfs_storage_class_authentik" {
  yaml_body          = templatefile("manifests/nfs-csi/nfs-storageClass-authentik.yaml", {
    nas_ip = local.ip_address.nas_ip
    root_path = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.nfs_csi_driver.metadata.0.name

  depends_on = [
    argocd_application.nfs_csi_driver
  ]
}

resource "kubectl_manifest" "nfs_storage_class_applications" {
  yaml_body          = templatefile("manifests/nfs-csi/nfs-storageClass-applications.yaml", {
    nas_ip = local.ip_address.nas_ip
    root_path = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.nfs_csi_driver.metadata.0.name

  depends_on = [
    argocd_application.nfs_csi_driver
  ]
}

resource "kubectl_manifest" "nfs_storage_class_influxdb" {
  yaml_body          = templatefile("manifests/nfs-csi/nfs-storageClass-influxdb.yaml", {
    nas_ip = local.ip_address.nas_ip
    root_path = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.nfs_csi_driver.metadata.0.name

  depends_on = [
    argocd_application.nfs_csi_driver
  ]
}

resource "kubectl_manifest" "nfs_storage_class_backup" {
  yaml_body          = templatefile("manifests/nfs-csi/nfs-storageClass-backup.yaml", {
    nas_ip = local.ip_address.nas_ip
    root_path = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.nfs_csi_driver.metadata.0.name

  depends_on = [
    argocd_application.nfs_csi_driver
  ]
}

resource "kubectl_manifest" "nfs_storage_class_redis" {
  yaml_body          = templatefile("manifests/nfs-csi/nfs-storageClass-redis.yaml", {
    nas_ip = local.ip_address.nas_ip
    root_path = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.nfs_csi_driver.metadata.0.name

  depends_on = [
    argocd_application.nfs_csi_driver
  ]
}

resource "kubectl_manifest" "nfs_storage_class_plex_media" {
  yaml_body          = templatefile("manifests/nfs-csi/nfs-storageClass-plex.yaml", {
    nas_ip = local.ip_address.nas_ip
    root_path = local.file_share.nas_plex_root
  })
  override_namespace = kubernetes_namespace.nfs_csi_driver.metadata.0.name

  depends_on = [
    argocd_application.nfs_csi_driver
  ]
}