# # Always having issues with LinkerD and updates...

# resource "argocd_repository" "linkerd" {
#   repo = "https://helm.linkerd.io/edge"
#   name = "linkerd"
#   type = "helm"
#   depends_on = [time_sleep.wait_for_argo]
# }

# ## Installing CRD's
# resource "helm_release" "linkerd-crd" {
#   repository = argocd_repository.linkerd.repo
#   chart      = "linkerd-crds"

#   namespace        = "linkerd"
#   create_namespace = false
#   name             = "linkerd-crds"
#   version          = var.linkerd_chart_version
# }

# resource "helm_release" "linkerd-cni" {
#   repository = argocd_repository.linkerd.repo
#   chart      = "linkerd2-cni"

#   namespace        = "linkerd"
#   create_namespace = false
#   name             = "linkerd-cni"
#   version          = var.linkerd_chart_version

#   set {
#     name = "priorityClassName"
#     value = "system-node-critical"
#   }
# }

# resource "tls_private_key" "ca" {
#   algorithm   = "ECDSA"
#   ecdsa_curve = "P384"
# }

# resource "tls_self_signed_cert" "ca" {
#   private_key_pem       = tls_private_key.ca.private_key_pem
#   is_ca_certificate     = true
#   set_subject_key_id    = true
#   validity_period_hours = 90600
#   allowed_uses = [
#     "cert_signing",
#     "crl_signing"
#   ]
#   subject {
#     common_name = "root.linkerd.cluster.local"
#   }
# }

# resource "tls_private_key" "issuer" {
#   algorithm   = "ECDSA"
#   ecdsa_curve = "P384"
# }

# resource "tls_cert_request" "issuer" {
#   private_key_pem = tls_private_key.issuer.private_key_pem
#   subject {
#     common_name = "identity.linkerd.cluster.local"
#   }
# }

# resource "tls_locally_signed_cert" "issuer" {
#   cert_request_pem      = tls_cert_request.issuer.cert_request_pem
#   ca_private_key_pem    = tls_private_key.ca.private_key_pem
#   ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
#   is_ca_certificate     = true
#   set_subject_key_id    = true
#   validity_period_hours = 2160
#   allowed_uses = [
#     "cert_signing",
#     "crl_signing"
#   ]
# }

# resource "argocd_application" "linkerd" {
#   metadata {
#     name = kubernetes_namespace.linkerd.metadata.0.name
#   }

#   spec {
#     project = argocd_project.argo-cd-system-project.metadata.0.name
#     source {
#       repo_url        = argocd_repository.linkerd.repo
#       chart           = "linkerd-control-plane"
#       target_revision = var.linkerd_chart_version

#       helm {
#         parameter {
#           name = "identityTrustAnchorsPEM"
#           value = tls_locally_signed_cert.issuer.ca_cert_pem
#         }
#         parameter {
#           name = "identity.issuer.tls.crtPEM"
#           value = tls_locally_signed_cert.issuer.cert_pem
#         }
#         parameter {
#           name = "identity.issuer.tls.keyPEM"
#           value = tls_private_key.issuer.private_key_pem
#         }
#         parameter {
#           name = "priorityClassName"
#           value = "system-cluster-critical"
#         }
#         parameter {
#           name = "cniEnabled"
#           # set to true when using CNI
#           value = true
#         }
#       }
#     }

#     sync_policy {
#       automated {
#         prune       = true
#         self_heal   = true
#         allow_empty = true
#       }
#       # Only available from ArgoCD 1.5.0 onwards
#       sync_options = ["Validate=false"]
#       retry {
#         limit = "5"
#         backoff {
#           duration     = "30s"
#           max_duration = "2m"
#           factor       = "2"
#         }
#       }
#     }

#     destination {
#       namespace = kubernetes_namespace.linkerd.metadata.0.name
#       name = "in-cluster"
#     }
#   }

#   depends_on = [
#     helm_release.linkerd-cni, 
#     helm_release.linkerd-crd
#   ]
# }