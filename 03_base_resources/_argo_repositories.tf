resource "argocd_repository" "k8s-homelab" {
  repo = "https://github.com/NigelVanHattum/k8s-homelab.git"
  name = "nigel-k8s-homelab"
  type = "git"
  depends_on = [time_sleep.wait_for_argo]
}