output "talosconfig" {
  value     = talos_machine_secrets.this.client_configuration
  sensitive = true
}

output "kubeconfig" {
  value     = data.talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}