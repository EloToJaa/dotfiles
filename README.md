# EloToJaa's dotfiles

My dotfile repository forked from [Frost-Phoenix/nixos-config](https://github.com/Frost-Phoenix/nixos-config/).

## Boot experience

The encrypted desktop and laptop profiles use a Plymouth LUKS password prompt themed with the configured Catppuccin flavor. Press `Esc` during boot to switch from the splash to the text console if graphical rendering is unavailable or boot diagnostics are needed.

## Credits

- [Frost-Phoenix/nixos-config](https://github.com/Frost-Phoenix/nixos-config).
- [KevinSilvester/wezterm-config](https://github.com/KevinSilvester/wezterm-config)
- [josean-dev/dev-environment-files](https://github.com/josean-dev/dev-environment-files/tree/main/.config/nvim)

## TODO

- [x] Replace notifiarr with ntfy.sh in sonarr, radarr, bazarr, prowlarr, jellyfin
- [x] Upgrade jellyfin to 12.0
- [x] Replace trakt yamtrack
- [x] Finish lazygit setup
- [x] Remove language tools
- [x] Migrate from niri to hyprland
- [ ] Replace jellystat with streamystats
- [ ] Fix secrets migrate from sops
- [ ] Cleanup flake.nix
- [ ] Add goaccess
- [ ] Add url shortner (shlink?)
- [ ] Add scrutiny
- [ ] Fix theming in dms
- [ ] Add frigate
- [ ] Setup zen browser
- [ ] Config writable for codex/claude?
- [ ] Fix nix shell to use unstable packages
- [ ] Checkout wezterm
- [ ] Replace dms with omarchy shell?
- [ ] Cleanup home-assistant dashboard
