terraform {
  cloud {
    organization = "Nigel_dev"

    workspaces {
      project = "Homelab"
      name = "02_base_resources"
    }
  }
}