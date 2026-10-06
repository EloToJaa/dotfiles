# worker and hbox provisioning

Both machines follow server's `configuration.nix` → `config.nix` structure and
import `nixosModules/server.nix` alongside srvos. This enables the repository's
base user/home-manager setup, password-authenticated sudo, Tailscale, Podman,
NFS automounts, graphics support and homelab groups. Both use the server
home-manager profile. SSH remains key-only. Networking uses networkd and public
DNS instead of NetworkManager/private DNS; the profile's Limine bootloader is
disabled in favor of worker's systemd-boot and hbox's VM GRUB profile.

Btrfs scrub/snapshot policy lives in machine configurations, not generic
server/desktop/laptop profiles. worker uses XFS with no Btrfs services. hbox
scrubs Btrfs and snapshots its actual `/`, `/nix` and `/var/lib` subvolumes.
Existing Btrfs machines retain their policies; ext4 miro no longer inherits
inappropriate Btrfs jobs. worker has an 8 GiB swapfile on its encrypted XFS root;
hbox has no swap configured.

- **worker:** x86_64 Intel, single disk, XFS root, UEFI/systemd-boot.
  Confirm UEFI boot is available and Secure Boot is disabled before installing.
- **hbox:** x86_64 Hetzner **Cloud** VM (not dedicated hardware), Btrfs root,
  `/nix` and `/var/lib` subvolumes, GRUB with BIOS and removable UEFI support,
  virtio drivers and QEMU guest agent via the opt-in `nixosModules/vm.nix`
  profile. That profile defaults GRUB's disk to `/dev/sda`; hbox overrides it
  with its disko device. Select an x86_64, not ARM, instance.

## Before installation

1. **Disk formatting destroys all data on the selected disk.** Both
   `disko.nix` files default to `/dev/sda`. Inspect `lsblk -o NAME,SIZE,MODEL,SERIAL`
   and `/dev/disk/by-id` on each target, verify the disk, and change
   `disko.devices.disk.main.device` if necessary (prefer a stable by-id path for
   worker). hbox GRUB follows that setting. `facter.json` reports for both hosts
   are intentionally deferred for the user to generate later. No reports are
   fabricated; review the real reports and adjust drivers before installation.
2. Fill in `deploy.targetHost` for each inventory entry in
   `machines/flake-module.nix`, using the actual address and configured admin
   username (`settings.username`, currently `elotoja`). No deployment IPs are
   supplied here. Installation/rescue SSH access is separate from the final
   key-only admin account; verify `settings.ssh.keys.user` is your key. The
   account's password comes from the base profile's Clan password generator;
   sudo requires that password. SSH password login and root SSH are disabled.
3. Networking assumes a wired `en*`/`eth*` uplink, DHCPv4 and IPv6 RA. Confirm
   interface names and DHCP availability from the target/rescue environment.
   Hetzner public IPv4 normally supports DHCP; configure the actual assigned
   IPv6 address/prefix and gateway explicitly if needed, or disable IPv6 until
   configured. IPv6-only/private-network instances need explicit network
   settings before installation. No addresses or gateways are invented.
   DNS uses public resolvers, not the repository's private LAN resolver.
4. Provision Clan SOPS recipients and generate vars for each host with
   `clan vars generate worker` and `clan vars generate hbox`. This includes
   inventory-provided root/emergency credentials, the shared
   `${settings.username}-password` hash (currently `elotoja-password`), the
   shared Tailscale auth key and hbox's `matrix-registration/token`. Have the
   operator password and Tailscale enrollment credentials ready; review any
   other generators contributed by home-manager. Inspect `clan vars list hbox`
   and retrieve the
   registration token securely via Clan when creating accounts. Never commit
   plaintext credentials. Verify generated host access and recovery credentials
   before installation.
5. hbox reuses the **existing encrypted** `secrets/secrets.yaml` entry
   `cloudflare/apitoken` for nginx DNS-01 ACME. This is a legacy input, not a new
   plaintext secret location. Securely provision a matching decryption identity
   at `/var/lib/sops-nix/key.txt` (root-owned, mode 0600), including during first
   installation before secret activation. Alternatively migrate the credential
   into encrypted `sops/` storage and update `defaultSopsFile` and recipients.
   The Cloudflare token needs DNS-edit permissions for the `elotoja.com` zone;
   neither the token nor a decryption key is created by this change.

## Hetzner guide adaptation

See the [Clan 26.05 Hetzner guide](https://clan.lol/docs/26.05/getting-started/getting-started-hetzner/).
Use an x86_64 Cloud instance, temporary Ubuntu image, **Public IPv4**, and your
SSH public key for initial root access. This repository already has a Clan and
both machine entries: do not run `clan init`, create another machine, or apply
the guide's ext4 disk template over hbox's Btrfs configuration.

The guide uses the internet instance for bootstrap reachability. Once the real
address is known, set
`inventory.instances.internet.roles.default.machines.hbox.settings.host` in
`machines/flake-module.nix` and use `settings.user = "root"` for the temporary
Ubuntu/rescue connection. Run `clan machines init-hardware-config hbox` against
that real target and review the generated hardware configuration. Keep the
reviewed disk device and Btrfs layout here. Before subsequent NixOS updates,
change the internet role's user to `settings.username` (currently `elotoja`),
since this profile disables root SSH. Keep `deploy.targetHost` consistent with
that destination; do not leave an internet role pointing at a different host.

An operator can then use `clan machines install hbox` after completing the
prerequisites above. If SSH reports a changed host key after replacement of
Ubuntu, verify the new fingerprint through a trusted console before removing
the old known_hosts entry. Back up the operator's Clan age key as advised by
the guide. No installation or hardware-gathering command was run for this change.

## hbox DNS, TLS and Matrix

Point `matrix.elotoja.com` to the actual hbox public address (DNS-only, no
Cloudflare proxy recommended). Publish AAAA only once IPv6 works. Allow TCP
22 for administration and TCP 80/443 through the Hetzner Cloud firewall;
Matrix's internal port 6167 must remain private. Allow outbound DNS/HTTPS for
ACME, package downloads and federation.

Matrix identity is **`@user:elotoja.com`**, while the client/federation endpoint
is **`https://matrix.elotoja.com`**. Do not change `serverName` after first use;
back up `/var/lib/tuwunel` (or the configured Tuwunel state directory) and Clan
vars before upgrades/migration. Btrfs subvolumes are not backups.

nginx serves discovery at `https://elotoja.com/.well-known/matrix/server` and
`https://elotoja.com/.well-known/matrix/client`, delegating to
`matrix.elotoja.com:443`. The apex must reach hbox, or its existing web host must
serve/proxy these exact discovery responses with valid TLS and client CORS.
Do not move an existing apex website without arranging that delegation.
Homelab domains retain their defaults: mainDomain is `elotoja.com` and baseDomain
is `hbox.elotoja.com`. Matrix's independent `endpointDomain` selects
`matrix.elotoja.com`, using the main-domain apex/wildcard certificate. nginx
also manages the default `hbox.elotoja.com` apex/wildcard certificate; neither
certificate is duplicated. Verify both well-known URLs, certificates, client
login and federation after installation.

## Deferred nixbot integration

`machines/hbox/config.nix` contains the explicit integration point.
After the user merges the real nixbot module, import/enable it there and add
only its actual required dependencies, secrets and firewall rules. No nixbot
service or dependency is assumed here.

## Verification and deployment

Run `nix fmt`, then build
`nix build .#nixosConfigurations.worker.config.system.build.toplevel` and
`nix build .#nixosConfigurations.hbox.config.system.build.toplevel`.
Only after all prerequisites and destructive-disk checks are complete should
an operator install using Clan and later deploy with `clan machines update`.
These instructions do not perform installation, formatting or deployment.
