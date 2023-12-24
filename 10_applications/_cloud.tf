terraform {
  cloud {
    organization = "Nigel_dev"

    workspaces {
      project = "Homelab"
      name = "10_storage"
    }
  }
}