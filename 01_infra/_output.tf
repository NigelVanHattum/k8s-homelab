output "talosconfig" {
  value     = talos_machine_secrets.this.client_configuration
  sensitive = true
}

output "kube_host" {
  value     = data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
  sensitive = true
}

output "kube_cluster_ca" {
  value     = data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate
  sensitive = true
}

output "kube_client_cert" {
  value     = data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate
  sensitive = true
}

output "kube_client_key" {
  value     = data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key
  sensitive = true
}

output "kubeconfig" {
  value     = data.talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}