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