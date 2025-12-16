resource "argocd_project" "argo_cd_apps_project" {
  metadata {
    name      = "apps"
  }

  spec {
    description = "project for applications"
    source_repos      = ["*"]

    destination {
      server = "*"
      name = "*"
      namespace = "mediaserver"
    }

    destination {
      server = "*"
      name = "*"
      namespace = "firefly"
    }

    destination {
      server = "*"
      name = "*"
      namespace = kubernetes_namespace.open_webui.metadata.0.name
    }

    destination {
      server = "*"
      name = "*"
      namespace = kubernetes_namespace.floatplane.metadata.0.name
    }

    destination {
      server = "*"
      name = "*"
      namespace = kubernetes_namespace.plex_management.metadata.0.name
    }

    destination {
      server = "*"
      name = "*"
      namespace = kubernetes_namespace.heimdall.metadata.0.name
    }

    destination {
      server = "*"
      name = "*"
      namespace = kubernetes_namespace.litellm.metadata.0.name
    }

    destination {
      server = "*"
      name = "*"
      namespace = kubernetes_namespace.mealie.metadata.0.name
    }

    destination {
      server = "*"
      name = "*"
      namespace = kubernetes_namespace.n8n.metadata.0.name
    }
    
    destination {
      server = "*"
      name = "*"
      namespace = kubernetes_namespace.kasm.metadata.0.name
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
