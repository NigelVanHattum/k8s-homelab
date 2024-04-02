locals {
    domain = "nigelvanhattum.nl"
    onepassword = {
        vault_name = "Homelab"
        azure_tenant = "Azure tenant"
        argocd_admin = "ArgoCD admin login"
        argocd_azure_secret = "ArgoCD Azure Secret"
        cloudflare_api_token = "Cloudflare DNS token"
    }
    ip_address = {
        ingress = "10.0.49.25"
        extra_pool = "10.0.49.40-10.0.49.50"
    }
}