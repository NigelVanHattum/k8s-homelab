output "oauth_client_id" {
  description = "Client ID of the OAuth provider"
  value       = authentik_provider_oauth2.app.client_id
  sensitive   = true
}

output "oauth_client_secret" {
  description = "Client secret of the OAuth provider"
  value       = authentik_provider_oauth2.app.client_secret
  sensitive   = true
}

output "oauth_well_known_url" {
  description = "Client secret of the OAuth provider"
  value       = data.authentik_provider_oauth2_config.app.provider_info_url
  sensitive   = true
}
