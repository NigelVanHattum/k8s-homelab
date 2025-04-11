output "talosconfig" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "kube_host" {
  value     = talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
  sensitive = true
}

output "kube_cluster_ca" {
  value     = talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate
  sensitive = true
}

output "kube_client_cert" {
  value     = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate
  sensitive = true
}

output "kube_client_key" {
  value     = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}

output "instructions" {
  value = "Kubeconfig has been stored in ${var.kube_config_path}/${var.cluster_name}, you need to manually move it to your desired location"
  sensitive = false
}

resource "local_sensitive_file" "talosconfig" {
  content         = data.talos_client_configuration.this.talos_config
  filename        = pathexpand("${var.talos_config_path}/${var.cluster_name}.yaml")
  file_permission = "0644"
}

resource "local_sensitive_file" "kubeconfig" {
  content         = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename        = pathexpand("${var.kube_config_path}/${var.cluster_name}")
  file_permission = "0644"
}