resource "helm_release" "argocd" {
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  namespace        = kubernetes_namespace.argocd.metadata.0.name
  create_namespace = false
  name             = "argocd"
  version          = var.argocd_chart_version

  values = [
    templatefile("helm-values/argocd.yaml", {
      tenant_id = var.azure_tenant_id
      client_id = var.azure_client_id
      client_secret = var.azure_client_secret
      entra_admin_group_id = var.entra_admin_group_id
      argocd_admin_password = random_password.argocd_admin_password.bcrypt_hash
    })
  ]
  depends_on = [helm_release.linkerd]
}

resource "argocd_project" "argo-cd-system-project" {
  metadata {
    name      = "system"
  }

  depends_on = [time_sleep.wait_for_argo]

  spec {
    description = "project for system applications"
    source_repos      = ["*"]

    destination {
      server = "*"
      name = "*"
      namespace = "nfs-csi-driver"
    }

    destination {
      server = "*"
      name = "*"
      namespace = "metal-lb"
    }

    destination {
      server = "*"
      name = "*"
      namespace = "traefik"
    }

    destination {
      server = "*"
      name = "*"
      namespace = "linkerd"
    }

    destination {
      server = "*"
      name = "*"
      namespace = "postgresql"
    }

    destination {
      server = "*"
      name = "*"
      namespace = "authentik"
    }

    destination {
      server = "*"
      name = "*"
      namespace = "influxdb"
    }

    destination {
      server = "*"
      name = "*"
      namespace = "skooner"
    }

    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }

    orphaned_resources {
      warn = true
    }
  }
}

resource "argocd_project" "argo_cd_apps_project" {
  metadata {
    name      = "apps"
  }

  depends_on = [time_sleep.wait_for_argo]

  spec {
    description = "project for system applications"
    source_repos      = ["*"]

    destination {
      server = "*"
      name = "*"
      namespace = "mediaserver"
    }
    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }

    orphaned_resources {
      warn = true
    }
  }
}

resource "time_sleep" "wait_for_argo" {
  depends_on = [helm_release.argocd]

  create_duration = "10s"
}
