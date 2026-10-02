resource "cloudflare_zone" "managed" {
  for_each = var.cloudflare_zones

  account = { id = each.value.account_id }
  name    = each.key
  type    = each.value.type
}

resource "cloudflare_dns_record" "managed" {
  for_each = var.cloudflare_dns_records

  zone_id  = cloudflare_zone.managed[each.value.zone].id
  name     = each.value.name
  type     = each.value.type
  content  = each.value.content
  ttl      = each.value.ttl
  proxied  = each.value.proxied
  priority = each.value.priority
}

# Import the existing policy before enabling this resource. It replaces the entire policy.
resource "tailscale_acl" "current" {
  count = var.tailscale_policy_file == null ? 0 : 1

  acl                        = file(var.tailscale_policy_file)
  overwrite_existing_content = false
  reset_acl_on_destroy       = false

  lifecycle {
    prevent_destroy = true
  }
}

# Opt-in worker with public IPv4 and IPv6 for initial SSH access.
resource "hcloud_server" "worker" {
  count = var.worker_enabled ? 1 : 0

  name        = "worker"
  image       = "debian-12"
  server_type = "cx23"
  location    = "fsn1"
  ssh_keys    = var.worker_ssh_keys

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  lifecycle {
    precondition {
      condition     = length(var.worker_ssh_keys) > 0
      error_message = "Set worker_ssh_keys to at least one existing Hetzner SSH key before enabling the worker."
    }
  }
}

resource "hcloud_storage_box_subaccount" "managed" {
  for_each = var.storage_box_subaccounts

  storage_box_id = each.value.storage_box_id
  name           = each.value.name
  home_directory = each.value.home_directory
  password       = var.storage_box_subaccount_passwords[each.key]
  description    = each.value.description

  access_settings = {
    reachable_externally = each.value.reachable_externally
    readonly             = each.value.readonly
    samba_enabled        = each.value.samba_enabled
    ssh_enabled          = each.value.ssh_enabled
    webdav_enabled       = each.value.webdav_enabled
  }

  lifecycle {
    prevent_destroy = true
  }
}
