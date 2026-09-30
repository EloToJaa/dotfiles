#!/usr/bin/env bash
set -euo pipefail

if (($# == 0)); then
  echo 'Usage: VAULT_CLOUDFLARE_PATH=... VAULT_TAILSCALE_PATH=... VAULT_HCLOUD_PATH=... terraform/with-vault.sh <terraform arguments>' >&2
  exit 2
fi

for tool in vault jq terraform; do
  command -v "$tool" >/dev/null || {
    echo "Missing $tool (enter nix develop)" >&2
    exit 1
  }
done

for name in VAULT_CLOUDFLARE_PATH VAULT_TAILSCALE_PATH VAULT_HCLOUD_PATH; do
  if [[ -z ${!name:-} ]]; then
    echo "Set $name to a Vault KV v2 secret path" >&2
    exit 2
  fi
done

# Read secrets into the process environment, never into .tfvars or the shell history.
read_field() {
  vault kv get -format=json "$1" | jq -er --arg field "$2" '.data.data[$field] | strings | select(length > 0)'
}

export CLOUDFLARE_API_TOKEN="$(read_field "$VAULT_CLOUDFLARE_PATH" token)"
export TAILSCALE_API_KEY="$(read_field "$VAULT_TAILSCALE_PATH" token)"
export HCLOUD_TOKEN="$(read_field "$VAULT_HCLOUD_PATH" token)"

if [[ -n ${VAULT_STORAGE_BOX_PASSWORDS_PATH:-} ]]; then
  # Secret's `passwords` field is a JSON object: {"account-key":"password"}.
  export TF_VAR_storage_box_subaccount_passwords="$(vault kv get -format=json "$VAULT_STORAGE_BOX_PASSWORDS_PATH" | jq -c -e '.data.data.passwords | if type == "string" then fromjson else . end | select(type == "object")')"
fi

exec terraform -chdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" "$@"
