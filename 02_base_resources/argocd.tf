resource "helm_release" "argocd" {
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  namespace        = kubernetes_namespace.argocd.metadata.0.name
  create_namespace = false
  name             = "argocd"
  version          = var.argocd_chart_version

  values = [
    templatefile("helm-values/argocd.yaml", {
      tenant_id = data.onepassword_item.azure_tenant_id.password
      client_id = data.onepassword_item.argocd_azure_credentials.note_value
      client_secret = data.onepassword_item.argocd_azure_credentials.password
      entra_admin_group_id = var.entra_admin_group_id
      argocd_admin_password = random_password.argocd_admin_password.bcrypt_hash
    })
  ]
  depends_on = [
    onepassword_item.argo_admin_password
    ]
}

resource "kubectl_manifest" "argo_public_ingress" {
  validate_schema = false
  yaml_body = file("${path.module}/manifests/ingress/argo.yaml")
  ## wait does not work, there is no status viewer for it
  # wait {
  #   rollout = true
  # }
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
      namespace = "kube-system"
    }

    destination {
      server = "*"
      name = "*"
      namespace = "nfs-csi-driver"
    }
    
    destination {
      server = "*"
      name = "*"
      namespace = "nfs-csi-driver"
    }

    destination {
      server = "*"
      name = "*"
      namespace = "iscsi-csi-driver"
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
      namespace = kubernetes_namespace.cert_manager.metadata.0.name
    }

    destination {
      server = "*"
      name = "*"
      namespace = kubernetes_namespace.intel_gpu.metadata.0.name
    }

    destination {
      server = "*"
      name = "*"
      namespace = kubernetes_namespace.nfd.metadata.0.name
    }

    destination {
      server = "*"
      name = "*"
      namespace = "grafana"
    }

    destination {
      server = "*"
      name = "*"
      namespace = "picture-of-the-day"
    }

    destination {
      server = "*"
      name = "*"
      namespace = "adguard"
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
