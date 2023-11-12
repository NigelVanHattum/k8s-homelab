resource "argocd_project" "argo-cd-system-project" {
  metadata {
    name      = "system"
  }

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

    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }

    orphaned_resources {
      warn = true
    }
  }
}