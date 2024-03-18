terraform {
  cloud {
    organization = "Nigel_dev"

    workspaces {
      project = "Homelab"
      name = "01_infra"
    }
  }
}