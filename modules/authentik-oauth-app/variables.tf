variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "app_slug" {
  description = "Slug for the application. If not provided, app_name will be used"
  type        = string
  default     = ""
}

variable "authorization_flow_id" {
  description = "ID of the authorization flow"
  type        = string
}

variable "invalidation_flow_id" {
  description = "ID of the invalidation flow"
  type        = string
}

variable "property_mappings" {
  description = "List of property mapping IDs"
  type        = list(string)
}

variable "redirect_uris" {
  description = "List of allowed redirect URIs"
  type        = list(string)
}

variable "group_bindings" {
  description = "List of group bindings with group ID and order"
  type = list(object({
    group_id = string
    order    = number
  }))
  default = []
}