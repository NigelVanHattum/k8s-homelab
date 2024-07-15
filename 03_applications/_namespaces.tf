resource "kubernetes_namespace" "firefly" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "firefly"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "kubernetes_namespace" "floatplane" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "floatplane"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "kubernetes_namespace" "plex_management" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "plex-management"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "kubernetes_namespace" "heimdall" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "heimdall"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "kubernetes_namespace" "mealie" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "mealie"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}