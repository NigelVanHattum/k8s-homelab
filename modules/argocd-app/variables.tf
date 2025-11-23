variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "namespace" {
  description = "kubernetes namespace for deployment"
  type        = string
}

variable "argocd_project" {
  type        = string
  default     = "apps"
}

variable "sync_options" {
  type        = list(string) 
  default     = []
}

variable "helm_values" {
  type        = string
  default     = ""
}

variable "chart" {
  type        = object({
    repo_url    = string,
    repo_exists = optional(bool, false),
    oci_repo    = optional(bool, false),
    chart       = string,
    version     = string
  })
}

variable "ignore_differences" {
  description = "List of ignoreDifferences rules for ArgoCD Application"
  type = list(object({
    group                 = string
    kind                  = string
    name                  = string
    jq_path_expressions   = optional(list(string), null)
    json_pointers         = optional(list(string), null)
  }))
  default = null
}