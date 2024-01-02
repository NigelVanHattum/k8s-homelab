terraform {
  cloud {
    organization = "Nigel_dev"

    workspaces {
      project = "Homelab"
      name = "03_base_resources"
    }
  }
}