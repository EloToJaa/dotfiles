# EloToJaa's dotfiles

My dotfile repository forked from [Frost-Phoenix/nixos-config](https://github.com/Frost-Phoenix/nixos-config/).

## Infrastructure

Terraform configuration for Cloudflare DNS, Tailscale policy, and Hetzner Storage Box subaccounts is in [terraform/](terraform/README.md). Follow the import and Vault setup instructions there before applying changes.

## Services

Homelab services, also shown on the [Glance dashboard](https://home.server.elotoja.com). The list is generated from `modules.homelab.glance.sites`; regenerate it with `just readme`.

<!-- services:start -->

|                                                                                                                   | Service                                                 | Group          | Host     |
| ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- | -------------- | -------- |
| <img src="https://api.iconify.design/mdi/brain.svg?color=%23888888" width="20" height="20">                       | [ai-memory](https://memory.server.elotoja.com)          | apps           | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/atuin.svg" width="20" height="20">          | [Atuin](https://atuin.server.elotoja.com)               | apps           | `server` |
| <img src="https://api.iconify.design/mdi/api.svg?color=%23888888" width="20" height="20">                         | [CLI Proxy API](https://hub.server.elotoja.com)         | apps           | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/immich.svg" width="20" height="20">         | [Immich](https://photos.server.elotoja.com)             | apps           | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/karakeep.svg" width="20" height="20">       | [Karakeep](https://hoarder.server.elotoja.com)          | apps           | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/paperless-ngx.svg" width="20" height="20">  | [Paperless-ngx](https://docs.server.elotoja.com)        | apps           | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/vaultwarden.svg" width="20" height="20">    | [Vaultwarden](https://pwd.server.elotoja.com)           | apps           | `server` |
| <img src="https://api.iconify.design/mdi/calendar-sync.svg?color=%23888888" width="20" height="20">               | [Xandikos](https://dav.server.elotoja.com)              | apps           | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/yamtrack.svg" width="20" height="20">       | [Yamtrack](https://track.server.elotoja.com)            | apps           | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/authelia.svg" width="20" height="20">       | [Authelia](https://auth.server.elotoja.com)             | auth           | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/lldap.svg" width="20" height="20">          | [lldap](https://lldap.server.elotoja.com)               | auth           | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/nixos.svg" width="20" height="20">          | [Harmonia](https://cache.worker.elotoja.com)            | ci             | `worker` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/nixos.svg" width="20" height="20">          | [Nixbot](https://nixbot.elotoja.com)                    | ci             | `worker` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/t3-chat.png" width="20" height="20">        | [T3 Code](https://t3.worker.elotoja.com)                | ci             | `worker` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/home-assistant.svg" width="20" height="20"> | [Home Assistant](https://hass.server.elotoja.com)       | home           | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/zigbee2mqtt.svg" width="20" height="20">    | [Zigbee2MQTT](https://z2m.server.elotoja.com)           | home           | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/pgadmin.svg" width="20" height="20">        | [pgAdmin](https://pgadmin.server.elotoja.com)           | infrastructure | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/bazarr.svg" width="20" height="20">         | [Bazarr](https://bazarr.server.elotoja.com)             | media          | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/cleanuparr.png" width="20" height="20">     | [Cleanuparr](https://cleanuparr.server.elotoja.com)     | media          | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jellyfin.svg" width="20" height="20">       | [Jellyfin](https://watch.server.elotoja.com)            | media          | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/prowlarr.svg" width="20" height="20">       | [Prowlarr](https://prowlarr.server.elotoja.com)         | media          | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/qbittorrent.svg" width="20" height="20">    | [qBittorrent](https://qbit.server.elotoja.com)          | media          | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/qui.svg" width="20" height="20">            | [qui](https://download.server.elotoja.com)              | media          | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/radarr.svg" width="20" height="20">         | [Radarr](https://radarr.server.elotoja.com)             | media          | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jellyseerr.svg" width="20" height="20">     | [Seerr](https://request.server.elotoja.com)             | media          | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/sonarr.svg" width="20" height="20">         | [Sonarr](https://sonarr.server.elotoja.com)             | media          | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/alertmanager.svg" width="20" height="20">   | [Alertmanager](https://alertmanager.server.elotoja.com) | monitoring     | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/gatus.svg" width="20" height="20">          | [Gatus](https://status.server.elotoja.com)              | monitoring     | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/grafana.svg" width="20" height="20">        | [Grafana](https://grafana.server.elotoja.com)           | monitoring     | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/loki.svg" width="20" height="20">           | [Loki](https://loki.server.elotoja.com)                 | monitoring     | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/ntfy.svg" width="20" height="20">           | [ntfy](https://ntfy.server.elotoja.com)                 | monitoring     | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/prometheus.svg" width="20" height="20">     | [Prometheus](https://prometheus.server.elotoja.com)     | monitoring     | `server` |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/tempo.svg" width="20" height="20">          | [Tempo](https://tempo.server.elotoja.com)               | monitoring     | `server` |

<!-- services:end -->

## Boot experience

The encrypted desktop and laptop profiles use a Plymouth LUKS password prompt themed with the configured Catppuccin flavor. Press `Esc` during boot to switch from the splash to the text console if graphical rendering is unavailable or boot diagnostics are needed.

## Credits

- [Frost-Phoenix/nixos-config](https://github.com/Frost-Phoenix/nixos-config).
- [KevinSilvester/wezterm-config](https://github.com/KevinSilvester/wezterm-config)
- [josean-dev/dev-environment-files](https://github.com/josean-dev/dev-environment-files/tree/main/.config/nvim)

## TODO

- [ ] Add goaccess
- [ ] Add scrutiny
- [ ] Add frigate
- [ ] Setup zen browser
