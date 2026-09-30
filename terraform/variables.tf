variable "tailnet" {
  description = "Tailscale tailnet ID (or legacy tailnet name)."
  type        = string
  default     = null
}

variable "tailscale_policy_file" {
  description = "Absolute path to an exact copy of the existing tailnet policy. Null disables ACL management. Import before setting/applying."
  type        = string
  default     = null
}

variable "cloudflare_zones" {
  description = "Cloudflare zones to manage, keyed by domain. Import existing zones before apply."
  type = map(object({
    account_id = string
    type       = optional(string, "full")
  }))
  default = {}
}

variable "cloudflare_dns_records" {
  description = "DNS records to manage, keyed by a stable local identifier. Import existing records before apply."
  type = map(object({
    zone     = string
    name     = string
    type     = string
    content  = string
    ttl      = optional(number, 1)
    proxied  = optional(bool)
    priority = optional(number)
  }))
  default = {}

  validation {
    condition     = alltrue([for record in values(var.cloudflare_dns_records) : contains(keys(var.cloudflare_zones), record.zone)])
    error_message = "Each DNS record's zone must be a key in cloudflare_zones."
  }
}

variable "storage_box_subaccounts" {
  description = "Hetzner Storage Box subaccounts, keyed by a stable local identifier. Import existing accounts before apply."
  type = map(object({
    storage_box_id       = number
    name                 = string
    home_directory       = string
    description          = optional(string)
    reachable_externally = optional(bool, false)
    readonly             = optional(bool, false)
    samba_enabled        = optional(bool, false)
    ssh_enabled          = optional(bool, true)
    webdav_enabled       = optional(bool, false)
  }))
  default = {}
}

variable "storage_box_subaccount_passwords" {
  description = "Passwords keyed by subaccount identifier. Supplied from Vault via TF_VAR_...; stored in Terraform state."
  type        = map(string)
  sensitive   = true
  default     = {}
}
