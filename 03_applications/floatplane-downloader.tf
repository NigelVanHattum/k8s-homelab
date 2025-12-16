module "floatplane_downloader" {
  source = "../modules/argocd-app"

  depends_on = [
    kubectl_manifest.pv_floatplane_db,
    kubectl_manifest.pv_floatplane_media
  ]

  app_name  = "floatplane"
  namespace = kubernetes_namespace.floatplane.metadata.0.name
  chart = {
    repo_url    = data.terraform_remote_state.base_resources.outputs.homelab_helm_repo
    repo_exists = true
    chart       = "floatplane-downloader"
    version     = var.floatplane_downloader_chart_version
  }

  helm_values = templatefile("helm-values/floatplane.yaml",
    {
      username  = data.onepassword_item.floatplane.username
      password  = data.onepassword_item.floatplane.password
      plexToken = data.onepassword_item.plex_token.password
      mfaToken  = var.floatplane_mfa_token
  })
}

resource "kubectl_manifest" "pv_floatplane_db" {
  yaml_body = templatefile("manifests/storage/pv-floatplane-db.yaml", {
    ip_address    = local.ip_address.nas_ip,
    k8s_rootmount = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.floatplane.metadata.0.name
}

resource "kubectl_manifest" "pv_floatplane_media" {
  yaml_body = templatefile("manifests/storage/pv-floatplane-media.yaml", {
    ip_address     = local.ip_address.nas_ip,
    plex_rootmount = local.file_share.nas_plex_root
  })
  override_namespace = kubernetes_namespace.floatplane.metadata.0.name
}