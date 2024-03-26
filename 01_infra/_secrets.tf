### 1Password
data "onepassword_vault" "homelab_vault" {
  name = local.one_password_vault
}

data "onepassword_item" "proxmox" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = local.one_password_proxmox
}