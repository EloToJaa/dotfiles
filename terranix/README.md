# Terranix infrastructure

This configuration manages:

- the existing `elotoja.com` Cloudflare zone (records are intentionally not managed yet);
- the existing Hetzner Storage Box used by Borg, with external SSH access enabled and Samba, WebDAV, and ZFS visibility disabled.

OpenTofu state and downloaded providers are kept locally in `.terranix/`, which is ignored by Git.

## Credentials

The Cloudflare token already lives at `cloudflare.apitoken` in `secrets/secrets.yaml`. It needs `Zone:Read` and `Zone:Edit` permissions for `elotoja.com`.

Add the remaining values with `sops secrets/secrets.yaml` under this structure:

```yaml
terranix:
  cloudflare_account_id: "..."
  hetzner_api_token: "..."
  storage_box:
    id: 12345
    location: fsn1
    name: borgbackup
    password: "..."
    type: bx21
```

Use the numeric Storage Box API ID, not the `u441859` username. The Storage Box must be visible in the Hetzner project associated with `hetzner_api_token`.

## Adopt and apply

The Hetzner resource has a declarative import block, so it is adopted during the first plan/apply. Import the existing Cloudflare zone once using its zone ID:

```bash
just infra-init
just infra-import-cloudflare <cloudflare-zone-id>
just infra-plan
just infra-apply
```

Review the first plan carefully. In particular, ensure the Storage Box type, location, and name match the existing resource. Both resources use `prevent_destroy`; the Storage Box also enables Hetzner delete protection.

After adoption, use:

```bash
just infra-plan
just infra-apply
```
