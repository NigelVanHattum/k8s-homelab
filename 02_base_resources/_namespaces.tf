resource "kubernetes_namespace" "linkerd" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "linkerd"
  }
}

resource "kubernetes_namespace" "grafana" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "grafana"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "argo"
  }
}

resource "kubernetes_namespace" "nfs_csi_driver" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "nfs-csi-driver"
  }
}

resource "kubernetes_namespace" "metallb" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "metal-lb"
  }
}

resource "kubernetes_namespace" "traefik" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "traefik"
  }
}

resource "kubernetes_namespace" "postgresql" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "postgresql"
  }
}

resource "kubernetes_namespace" "postgresql_recovery" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "postgresql-recovery"
  }
}

resource "kubernetes_namespace" "influxdb" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "influxdb"
  }
}

resource "kubernetes_namespace" "picture_of_the_day" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "picture-of-the-day"
  }
}

resource "kubernetes_namespace" "authentik" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "authentik"
  }
}