locals {
  master_ips       = [for master in var.master_vms : master.ip_address]
  cluster_name     = "talos-homelab"
  cluster_endpoint = "https://${local.master_ips[0]}:6443"
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = local.cluster_name
  cluster_endpoint = local.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_machine_configuration" "worker" {
  cluster_name     = local.cluster_name
  cluster_endpoint = local.cluster_endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_client_configuration" "this" {
  cluster_name         = local.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = local.master_ips
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on = [
    proxmox_vm_qemu.talos-controlpane
  ]

  for_each = var.master_vms

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value.ip_address
  config_patches = [
    file("${path.module}/talos_config_patches/cert-rotate-patch.yaml"),
    templatefile("${path.module}/talos_config_patches/hostname-config.yaml", {
      hostname = each.key
    })
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  depends_on = [
    proxmox_vm_qemu.talos-worker
  ]

  for_each = var.worker_vms

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value.ip_address
  config_patches = [
    file("${path.module}/talos_config_patches/cert-rotate-patch.yaml"),
    templatefile("${path.module}/talos_config_patches/hostname-config.yaml", {
      hostname = each.key
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.controlplane,
    talos_machine_configuration_apply.worker
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.master_ips[0]
}

data "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.master_ips[0]
}

# Add cert signing and enable the metric server
data "http" "cert_approver_download" {
  url = "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml"
}

data "http" "metric_server_download" {
  url = "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
}

data "kubectl_file_documents" "cert_approver" {
    content = data.http.cert_approver_download.response_body
}

data "kubectl_file_documents" "metric_server" {
    content = data.http.metric_server_download.response_body
}

resource "time_sleep" "wait_for_talos_boot" {
  depends_on = [talos_machine_bootstrap.this]

  ### Talos needs some time to boot after bootstrap.
  create_duration = "2m"
}

resource "kubectl_manifest" "cert_approver" {
  for_each = data.kubectl_file_documents.cert_approver.manifests
  yaml_body = each.value

  depends_on = [
    time_sleep.wait_for_talos_boot
  ]
}

resource "kubectl_manifest" "metric_server" {
  for_each = data.kubectl_file_documents.metric_server.manifests
  yaml_body = each.value

  depends_on = [
    time_sleep.wait_for_talos_boot
  ]
}
