# Terraform infrastructure

This directory manages Cloudflare zones and DNS records, the **entire** Tailscale tailnet policy, a Hetzner Cloud worker server, and Hetzner Storage Box subaccounts. It does not manage domain registration or the Storage Box itself. No resources are enabled by default; existing resources must be imported before applying their configuration.

## Local tools and state

Enter `nix develop` for `terraform`, `vault`, and `jq`. State is local and gitignored. **Do not commit state, plans, passwords, tokens, or real tfvars**: Storage Box passwords and DNS data can be present in state. Back up state securely, restrict file permissions, and never share it. The `.terraform.lock.hcl` dependency lockfile produced by `init` should be committed.

## Vault credentials

Log in using the Vault CLI (`vault login`, or an existing agent session with `VAULT_ADDR` and `VAULT_TOKEN`). Create four **KV v2** secrets at paths you choose, with these fields:

| Environment variable containing KV path | Field in secret | Purpose                                                                      |
| --------------------------------------- | --------------- | ---------------------------------------------------------------------------- |
| `VAULT_CLOUDFLARE_PATH`                 | `token`         | Cloudflare API token (zone and DNS read/write)                               |
| `VAULT_TAILSCALE_PATH`                  | `token`         | Tailscale API key with policy read/write                                     |
| `VAULT_HCLOUD_PATH`                     | `token`         | Hetzner Cloud API token with Storage Box access                              |
| `VAULT_STORAGE_BOX_PASSWORDS_PATH`      | `passwords`     | JSON object keyed by `storage_box_subaccounts` keys, e.g. `{"backup":"..."}` |

The last secret/path is only needed when managing subaccounts. Set these **path variables** in your shell or private environment; never store token values in Git. `./with-vault.sh` retrieves them with `vault kv get`, exports provider environment variables and the sensitive `TF_VAR_storage_box_subaccount_passwords`, then runs Terraform. It does not use the Terraform Vault provider: Terraform Vault data sources would put retrieved credentials in state. Subaccount **passwords still enter Terraform state** because the Hetzner resource requires them; Vault is not a state backend. Do not rotate a managed password outside Terraform without reconciling Vault and state.

## Adoption (no automatic apply)

1. Copy `terraform.tfvars.example` to `terraform.tfvars`. Replace examples with your **actual** account ID, domains, records, box ID and subaccounts; or remove example collections until ready. Existing DNS and storage subaccounts not listed remain unmanaged. Keep the `tailnet` ID for your tailnet. For existing subaccounts, store their current passwords in Vault before import.
2. Export the **complete existing policy** (including grants/ACLs, SSH, tags, tests and other sections) from the Tailscale admin console to `policy.hujson`, review it, then set `tailscale_policy_file = "./policy.hujson"`. Check this policy into Git only after review; do not use an example/default policy in its place. The ACL resource is off when the variable is null and is protected against destroy. Keep the policy file and variable set while it is managed.
3. Run `./with-vault.sh init` and import **each existing resource before any apply**:

   ```sh
   ./with-vault.sh import 'cloudflare_zone.managed["example.com"]' ZONE_ID
   ./with-vault.sh import 'cloudflare_dns_record.managed["www"]' ZONE_ID/RECORD_ID
   ./with-vault.sh import 'tailscale_acl.current[0]' acl
   ./with-vault.sh import 'hcloud_storage_box_subaccount.managed["backup"]' BOX_ID/SUBACCOUNT_ID
   ```

   Cloudflare record IDs and zone IDs are available in Cloudflare; Hetzner uses the numeric Storage Box ID (not the `u...` username). Import only the resources you actually own. When creating a **new** resource, no import is needed.

4. Run `./with-vault.sh plan` and inspect all proposed changes, especially policy replacement and password rotation, **before** `./with-vault.sh apply`. If the policy diff is unexpected, stop and reconcile the exported policy. Terraform will validate policy against Tailscale during planning. Never run `apply` just to discover drift.

## Hetzner worker (opt-in)

`hcloud_server.worker` is disabled by default. It uses `cx23` (the small, cost-optimized x86 plan), `fsn1`, and public IPv4 and IPv6 addresses. Hetzner charges extra for IPv4; check current pricing and availability before applying. Set `worker_enabled = true` and `worker_ssh_keys = ["your-existing-hetzner-key-name"]` in the ignored `terraform.tfvars`, then review `./with-vault.sh plan` before applying. The key must already exist in the Hetzner Cloud project; SSH keys cannot be changed on the server without replacement. If the server already exists, import it as `hcloud_server.worker[0]` before applying.

Terraform creates a Debian bootstrap host only. Install NixOS separately and configure the `worker` Clan machine, AI runner, CLIProxy, and Nixbot remote builds there; do not store application credentials in Terraform. The worker is publicly reachable over IPv4 and IPv6 until its firewall and host access are configured.

The repository's existing NixOS/Clan SOPS secrets are unaffected; Vault here is only for Terraform credentials and subaccount passwords.
