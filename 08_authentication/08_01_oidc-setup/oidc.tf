data "authentik_flow" "default-source-authentication" {
  slug = "default-source-authentication"
}

data "authentik_flow" "default-enrollment-flow" {
  slug = "default-source-enrollment"
}

resource "authentik_source_oauth" "name" {
  name                  = "azure-ad"
  slug                  = "azure-ad"
  authentication_flow   = data.authentik_flow.default-source-authentication.id
  enrollment_flow       = data.authentik_flow.default-enrollment-flow.id
#   user_matching_mode    = "email_link"
  provider_type         = "azuread"
  consumer_key          = var.azure_client_id
  consumer_secret       = var.azure_client_secret
  oidc_well_known_url   = "https://login.microsoftonline.com/${var.azure_tenant_id}/v2.0/.well-known/openid-configuration"
  additional_scopes     = "* openid profile email"
}