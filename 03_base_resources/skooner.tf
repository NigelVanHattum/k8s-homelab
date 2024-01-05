resource "argocd_repository" "skooner" {
  repo = "https://github.com/NigelVanHattum/k8s-homelab.git"
  name = "nigel-k8s-homelabe"
  type = "git"

  depends_on = [argocd_project.argo-cd-system-project]
}