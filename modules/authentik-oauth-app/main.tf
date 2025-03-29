resource "random_bytes" "oauth_client_id" {
  length            = 8
}

# To get the the ID and other info about a certificate

data "authentik_certificate_key_pair" "default" {
  name = "authentik Self-signed Certificate"
}

# Then use `data.authentik_certificate_key_pair.generated.id`

resource "authentik_provider_oauth2" "app" {
  name               = var.app_name
  client_id          = random_bytes.oauth_client_id.hex
  authorization_flow = var.authorization_flow_id
  allowed_redirect_uris = [
    for uri in var.redirect_uris : {
      matching_mode = "regex",
      url           = uri
    }
  ]
  invalidation_flow  = var.invalidation_flow_id
  property_mappings  = var.property_mappings
  signing_key = data.authentik_certificate_key_pair.default.id
}

data "authentik_provider_oauth2_config" "app" {
  provider_id = authentik_provider_oauth2.app.id
}

resource "authentik_application" "app" {
  name              = var.app_name
  slug              = var.app_slug != "" ? var.app_slug : var.app_name
  protocol_provider = authentik_provider_oauth2.app.id
}

resource "authentik_policy_binding" "group_bindings" {
  for_each = { for idx, binding in var.group_bindings : idx => binding }
  
  target = authentik_application.app.uuid
  group  = each.value.group_id
  order  = each.value.order
}