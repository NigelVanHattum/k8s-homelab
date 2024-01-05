resource "kubernetes_namespace" "mediaserver" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "mediaserver"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}