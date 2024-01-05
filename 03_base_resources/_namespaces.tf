resource "kubernetes_namespace" "linkerd" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "linkerd"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "argo"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "kubernetes_namespace" "nfs_csi_driver" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "nfs-csi-driver"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "kubernetes_namespace" "metallb" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "metal-lb"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "kubernetes_namespace" "traefik" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "traefik"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "kubernetes_namespace" "postgresql" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "postgresql"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "kubernetes_namespace" "influxdb" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "influxdb"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "kubernetes_namespace" "skooner" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "skooner"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}