data "authentik_flow" "default_authorization_flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_scope_mapping" "oidc_mapping" {
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