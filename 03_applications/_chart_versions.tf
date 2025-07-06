# https://github.com/firefly-iii/kubernetes/releases
variable "firefly_chart_version" {
  type = string
  description = "firefly-stack chart version"
  default = "0.8.8"
}

# https://github.com/NigelVanHattum/Homelab-Helm-charts/tree/master/charts/floatplane-downloader
variable "floatplane_downloader_chart_version" {
  type = string
  description = "fp-downloader chart version"
  default = "0.2.2"
}

# https://github.com/NigelVanHattum/Homelab-Helm-charts/tree/master/charts/plex-management
variable "plex_management_chart_version" {
  type = string
  default = "0.1.16"
}

# https://github.com/NigelVanHattum/Homelab-Helm-charts/tree/master/charts/heimdall
variable "heimdall_chart_version" {
  type = string
  default = "0.1.2"
}

# https://github.com/NigelVanHattum/Homelab-Helm-charts/tree/master/charts/mealie
variable "mealie_chart_version" {
  type = string
  default = "0.2.2"
}

# https://github.com/open-webui/helm-charts/releases
variable "open_webui_chart_version" {
  type = string
  default = "6.22.0"
}

# https://github.com/BerriAI/litellm/pkgs/container/litellm-helm
variable "litellm_chart_version" {
  type = string
  default = "0.1.713"
}