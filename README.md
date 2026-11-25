# EloToJaa's dotfiles

My dotfile repository forked from [Frost-Phoenix/nixos-config](https://github.com/Frost-Phoenix/nixos-config/).

## Infrastructure

Terraform configuration for Cloudflare DNS, Tailscale policy, and Hetzner Storage Box subaccounts is in [terraform/](terraform/README.md). Follow the import and Vault setup instructions there before applying changes.

## Services

Homelab services, also shown on the [Glance dashboard](https://home.server.elotoja.com). The list is generated from `modules.homelab.glance.sites`; regenerate it with `just readme`.

<!-- services:start -->

| Service                                                 | Group          | Host     |
| ------------------------------------------------------- | -------------- | -------- |
| [ai-memory](https://memory.server.elotoja.com)          | apps           | `server` |
| [Atuin](https://atuin.server.elotoja.com)               | apps           | `server` |
| [CLI Proxy API](https://hub.server.elotoja.com)         | apps           | `server` |
| [Forgejo](https://git.elotoja.com)                      | apps           | `hbox`   |
| [Immich](https://photos.server.elotoja.com)             | apps           | `server` |
| [Karakeep](https://hoarder.server.elotoja.com)          | apps           | `server` |
| [Matrix](https://matrix.elotoja.com)                    | apps           | `hbox`   |
| [Paperless-ngx](https://docs.server.elotoja.com)        | apps           | `server` |
| [Stalwart](https://mail.elotoja.com)                    | apps           | `hbox`   |
| [Vaultwarden](https://pwd.server.elotoja.com)           | apps           | `server` |
| [Xandikos](https://dav.server.elotoja.com)              | apps           | `server` |
| [Yamtrack](https://track.server.elotoja.com)            | apps           | `server` |
| [Authelia](https://auth.server.elotoja.com)             | auth           | `server` |
| [lldap](https://lldap.server.elotoja.com)               | auth           | `server` |
| [Harmonia](https://cache.worker.elotoja.com)            | ci             | `worker` |
| [Nixbot](https://nixbot.elotoja.com)                    | ci             | `worker` |
| [T3 Code](https://t3.worker.elotoja.com)                | ci             | `worker` |
| [Home Assistant](https://hass.miro.elotoja.com)         | home           | `miro`   |
| [Home Assistant](https://hass.server.elotoja.com)       | home           | `server` |
| [Zigbee2MQTT](https://z2m.server.elotoja.com)           | home           | `server` |
| [pgAdmin](https://pgadmin.miro.elotoja.com)             | infrastructure | `miro`   |
| [pgAdmin](https://pgadmin.server.elotoja.com)           | infrastructure | `server` |
| [Bazarr](https://bazarr.server.elotoja.com)             | media          | `server` |
| [Cleanuparr](https://cleanuparr.server.elotoja.com)     | media          | `server` |
| [Jellyfin](https://watch.miro.elotoja.com)              | media          | `miro`   |
| [Jellyfin](https://watch.server.elotoja.com)            | media          | `server` |
| [Prowlarr](https://prowlarr.server.elotoja.com)         | media          | `server` |
| [qBittorrent](https://qbit.server.elotoja.com)          | media          | `server` |
| [qui](https://download.server.elotoja.com)              | media          | `server` |
| [Radarr](https://radarr.server.elotoja.com)             | media          | `server` |
| [Seerr](https://request.server.elotoja.com)             | media          | `server` |
| [Sonarr](https://sonarr.server.elotoja.com)             | media          | `server` |
| [Alertmanager](https://alertmanager.server.elotoja.com) | monitoring     | `server` |
| [Gatus](https://status.server.elotoja.com)              | monitoring     | `server` |
| [Grafana](https://grafana.server.elotoja.com)           | monitoring     | `server` |
| [Loki](https://loki.server.elotoja.com)                 | monitoring     | `server` |
| [ntfy](https://ntfy.server.elotoja.com)                 | monitoring     | `server` |
| [Prometheus](https://prometheus.server.elotoja.com)     | monitoring     | `server` |
| [Tempo](https://tempo.server.elotoja.com)               | monitoring     | `server` |

<!-- services:end -->

## Boot experience

The encrypted desktop and laptop profiles use a Plymouth LUKS password prompt themed with the configured Catppuccin flavor. Press `Esc` during boot to switch from the splash to the text console if graphical rendering is unavailable or boot diagnostics are needed.

## Credits

- [Frost-Phoenix/nixos-config](https://github.com/Frost-Phoenix/nixos-config).
- [KevinSilvester/wezterm-config](https://github.com/KevinSilvester/wezterm-config)
- [josean-dev/dev-environment-files](https://github.com/josean-dev/dev-environment-files/tree/main/.config/nvim)

## TODO

- [x] Verify Nix daemon trust for `elotoja` and `@wheel`, assess root-equivalent access, and test Clan deployments without user trust before changing the policy
- [x] Set up a Hetzner box with NixOS for a Matrix server and Nixbot
- [x] Add a `worker` machine as the main AI runner, hosting CLIProxy and handling Nix builds for Nixbot
- [ ] Set up the Dreame vacuum card and buy the licence
- [x] Replace notifiarr with ntfy.sh in sonarr, radarr, bazarr, prowlarr, jellyfin
- [x] Upgrade jellyfin to 12.0
- [x] Replace trakt yamtrack
- [x] Finish lazygit setup
- [x] Remove language tools
- [x] Cleanup flake.nix
- [ ] Add goaccess
- [ ] Add url shortner (shlink?)
- [ ] Add scrutiny
- [ ] Add frigate
- [ ] Setup zen browser
- [ ] Config writable for codex/claude?
- [ ] Fix nix shell to use unstable packages
- [ ] Checkout wezterm
- [ ] Cleanup home-assistant dashboard
