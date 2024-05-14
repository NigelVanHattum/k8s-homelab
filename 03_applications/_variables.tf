### 1Password
variable "onepassword_service_token" {
  type    = string
  sensitive = true
  }

variable "floatplane_mfa_token" {
  type = string
  sensitive = true
  description = "OTP token for floatplane"
}