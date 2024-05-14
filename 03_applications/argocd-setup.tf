resource "argocd_repository" "my_homelab" {
  repo = "https://nigelvanhattum.github.io/Homelab-Helm-charts/"
  name = "my-homelab"
  type = "helm"
}

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
      namespace = "floatplane"
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
