resource "postgresql_role" "authentik" {
  name     = var.postgresql_authentik_username
  login    = true
  password = var.postgresql_authentik_password

  depends_on = [argocd_application.postgresql, kubernetes_manifest.postgres_ingress, argocd_application.traefik]
}

resource "postgresql_role" "hass" {
  name     = var.postgresql_hass_username
  login    = true
  password = var.postgresql_hass_password

  depends_on = [argocd_application.postgresql, kubernetes_manifest.postgres_ingress, argocd_application.traefik]
}