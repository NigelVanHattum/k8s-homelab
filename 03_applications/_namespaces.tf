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

resource "kubernetes_namespace" "open_webui" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "open-webui"
  }
}

resource "kubernetes_namespace" "litellm" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "lite-llm"
  }
}

resource "kubernetes_namespace" "n8n" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "n8n"
  }
}

resource "kubernetes_namespace" "kasm" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "kasm"
  }
}