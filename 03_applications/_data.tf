data "authentik_flow" "default_authorization_flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default_provider_invalidation_flow" {
  slug = "default-provider-invalidation-flow"
}

data "authentik_property_mapping_provider_scope" "oidc_mapping" {
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile"
  ]
}

data "authentik_group" "admin" {
  name = local.authentik.group_admin
}

data "authentik_group" "houshold" {
  name = local.authentik.group_household
}

data "authentik_group" "guests" {
  name = local.authentik.group_guests
}