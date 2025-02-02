locals {
  bootstrap_ip        = [for machine in var.all_vms : machine.ip_address if machine.type == "controlplane"][0]
  control_ips         = [for machine_key, machine in var.all_vms : machine.ip_address if machine.type == "controlplane"]
  cluster_endpoint  = "https://${local.bootstrap_ip}:6443"
}

resource "talos_machine_secrets" "this" {
  talos_version = local.talos_version
}

####################################################
#### SELECTING CORRECT TALOS IMAGE
####################################################

data "talos_image_factory_extensions_versions" "this" {
  for_each = var.all_vms

  # get the latest talos version
  talos_version = local.talos_version
  filters = {
    names = [
      "amd-ucode",
      "amdgpu-firmware",
      "util-linux-tools"
    ]
  }
}

resource "talos_image_factory_schematic" "this" {
  for_each = var.all_vms

  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this[each.key].extensions_info[*].name
        }
      }
    }
  )
}

data "talos_image_factory_urls" "machine_image_url" {
  for_each = var.all_vms

  talos_version = local.talos_version
  schematic_id  = talos_image_factory_schematic.this[each.key].id
  platform      = each.value.platform
}


####################################################
#### Talos upgrade via Terraform
####################################################
# Hack for: https://github.com/siderolabs/terraform-provider-talos/issues/140
resource "null_resource" "talos_upgrade_trigger" {
  for_each   = var.all_vms

  triggers = {
    desired_talos_tag    = data.talos_image_factory_urls.machine_image_url[each.key].talos_version
    desired_schematic_id = data.talos_image_factory_urls.machine_image_url[each.key].schematic_id
    stage_talos_upgrade  = var.stage_talos_upgrade
  }

  # Should only upgrade if there's a schematic mismatch
  provisioner "local-exec" {
    command = "flock $LOCK_FILE --command ${path.module}/upgrade-node.sh"

    environment = {
      LOCK_FILE = "${path.module}/.upgrade-node.lock"

      DESIRED_TALOS_TAG       = self.triggers.desired_talos_tag
      DESIRED_TALOS_SCHEMATIC = self.triggers.desired_schematic_id
      TALOS_CONFIG_PATH       = local_sensitive_file.talosconfig.filename
      TALOS_NODE              = each.key
      STAGE                   = self.triggers.stage_talos_upgrade
      TIMEOUT                 = "10m"
    }
  }
  depends_on = [null_resource.talos_cluster_health]
}

####################################################
#### Data objects
####################################################
data "talos_machine_configuration" "this" {
  for_each = var.all_vms

  cluster_name     = var.cluster_name
  cluster_endpoint = local.cluster_endpoint
  machine_type     = each.value.type
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = local.talos_version
}

data "talos_client_configuration" "this" {
  cluster_name          = var.cluster_name
  client_configuration  = talos_machine_secrets.this.client_configuration
  endpoints             = local.control_ips
  nodes                 = [for machine_key, machine in var.all_vms : machine.ip_address]
}

resource "talos_machine_configuration_apply" "this" {
  depends_on = [
    proxmox_vm_qemu.talos_machines
  ]

  for_each = var.all_vms

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[each.key].machine_configuration
  node                        = each.value.ip_address
  config_patches = [
    file("${path.module}/talos_config_patches/cert-rotate-patch.yaml"),
    templatefile("${path.module}/talos_config_patches/hostname-config.yaml", {
      hostname = each.key
    }),
    file("${path.module}/talos_config_patches/max-disk-size.yaml")
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.this
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.bootstrap_ip
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.bootstrap_ip
}


####################################################
#### Add cert signing and enable the metric server
####################################################
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

# data.talos_cluster_health does not work in the case of scaling-in nodes into an existing cluster.  See: https://github.com/siderolabs/terraform-provider-talos/issues/221
# Run a null resource provisioner callout to talos_cluster_health to get the same functionality.

# This prevents the module from reporting completion until the cluster is up and operational.
# tflint-ignore: terraform_unused_declarations
resource "null_resource" "talos_cluster_health" {
  depends_on = [talos_machine_bootstrap.this, talos_machine_configuration_apply.this]
  for_each   = { for name, machine in var.all_vms : name => machine if machine.type == "controlplane" }

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "talosctl --talosconfig $TALOSCONFIG health --nodes $NODE --wait-timeout $TIMEOUT"

    environment = {
      TALOSCONFIG = pathexpand(local_sensitive_file.talosconfig.filename)
      NODE        = each.key
      TIMEOUT     = "10m"
    }
  }
}

resource "kubectl_manifest" "cert_approver" {
  for_each = data.kubectl_file_documents.cert_approver.manifests
  yaml_body = each.value

  depends_on = [
    null_resource.talos_cluster_health
  ]
}

resource "kubectl_manifest" "metric_server" {
  for_each = data.kubectl_file_documents.metric_server.manifests
  yaml_body = each.value

  depends_on = [
    null_resource.talos_cluster_health
  ]
}
