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

resource "helm_release" "linkerd-crd" {
  repository = "https://helm.linkerd.io/stable"
  chart      = "linkerd-crds"

  namespace        = "linkerd"
  create_namespace = false
  name             = "linkerd-crds"
}

# resource "helm_release" "linkerd-cni" {
#   repository = "https://helm.linkerd.io/stable"
#   chart      = "linkerd2-cni"

#   namespace        = "linkerd"
#   create_namespace = false
#   name             = "linkerd-cni"
# }

resource "tls_private_key" "ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem       = tls_private_key.ca.private_key_pem
  is_ca_certificate     = true
  set_subject_key_id    = true
  validity_period_hours = 90600
  allowed_uses = [
    "cert_signing",
    "crl_signing"
  ]
  subject {
    common_name = "root.linkerd.cluster.local"
  }
}

resource "tls_private_key" "issuer" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "issuer" {
  private_key_pem = tls_private_key.issuer.private_key_pem
  subject {
    common_name = "identity.linkerd.cluster.local"
  }
}

resource "tls_locally_signed_cert" "issuer" {
  cert_request_pem      = tls_cert_request.issuer.cert_request_pem
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  is_ca_certificate     = true
  set_subject_key_id    = true
  validity_period_hours = 2160
  allowed_uses = [
    "cert_signing",
    "crl_signing"
  ]
}

resource "helm_release" "linkerd" {
  name       = "linkerd"
  repository = helm_release.linkerd-crd.repository
  chart      = "linkerd-control-plane"
  version    = var.linkerd_chart_version
  namespace   = kubernetes_namespace.linkerd.metadata.0.name

  # set {
  #   name = "cniEnabled"
  #   value = true
  # }

  set {
    name = "identityTrustAnchorsPEM"
    value = tls_locally_signed_cert.issuer.ca_cert_pem
  }

  set {
    name = "identity.issuer.tls.crtPEM"
    value = tls_locally_signed_cert.issuer.cert_pem
  }

  set {
    name = "identity.issuer.tls.keyPEM"
    value = tls_private_key.issuer.private_key_pem
  }
}