provider "proxmox" {
  pm_api_url = var.proxmox_url
  pm_api_token_id = var.proxmox_api_key_id
  pm_api_token_secret = var.proxmox_api_key_secret
  pm_tls_insecure = var.proxmox_tls_insecure

  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
  pm_debug      = true
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}