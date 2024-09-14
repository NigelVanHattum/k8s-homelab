resource "kubernetes_namespace" "firefly" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "firefly"
  }
}

resource "kubernetes_namespace" "floatplane" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "floatplane"
  }
}

resource "kubernetes_namespace" "plex_management" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "plex-management"
  }
}

resource "kubernetes_namespace" "heimdall" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "heimdall"
  }
}

resource "kubernetes_namespace" "mealie" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "mealie"
  }
}