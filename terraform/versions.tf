terraform {
  required_version = ">= 1.7.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.20"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.69.0, < 2.0.0"
    }
  }
}

# Provider credentials come from the environment, populated by ./with-vault.sh.
provider "cloudflare" {}
provider "tailscale" {
  tailnet = var.tailnet
}
provider "hcloud" {}
