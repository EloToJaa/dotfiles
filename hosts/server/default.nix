{variables, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./../../modules/base
    ./../../modules/homelab
    ./../../modules/settings.nix
  ];

  home-manager.users.${variables.username}.imports = [
    ./../../modules/home
  ];

  networking = {
    useDHCP = false;
    interfaces."enp1s0".ipv4.addresses = [
      {
        address = "192.168.0.32";
        prefixLength = 24;
      }
    ];
    defaultGateway = {
      address = "192.168.0.1";
      interface = "enp1s0";
    };
  };

  powerManagement.cpuFreqGovernor = "performance";

  modules = {
    homelab = {
      enable = true;
      atuin.enable = true;
      backup.enable = true;
      bazarr.enable = true;
      blocky.enable = true;
      caddy.enable = true;
      cleanuparr.enable = true;
      glance.enable = false;
      grafana.enable = false;
      home-assistant.enable = true;
      immich.enable = true;
      jellyfin.enable = true;
      jellyseerr.enable = true;
      jellystat.enable = true;
      karakeep.enable = true;
      loki.enable = false;
      nextcloud.enable = false;
      ntfy.enable = true;
      paperless.enable = true;
      postgres = {
        enable = true;
        pgadmin.enable = true;
      };
      prometheus.enable = false;
      prowlarr = {
        enable = true;
        flaresolverr.enable = true;
      };
      qbittorrent = {
        enable = true;
        vuetorrent.enable = true;
      };
      radarr.enable = true;
      radicale.enable = true;
      rustdesk.enable = false;
      sonarr.enable = true;
      uptime.enable = true;
      vaultwarden.enable = true;
      wireguard.enable = true;
    };
    home = {
      enable = true;
      lazygit.enable = true;
      nvim = {
        enable = true;
        languages = {
          enable = true;
          bash.enable = true;
          c.enable = false;
          go.enable = false;
          javascript.enable = false;
          json.enable = true;
          lua.enable = true;
          markdown.enable = true;
          nix.enable = true;
          python.enable = true;
          rust.enable = false;
          toml.enable = true;
          xml.enable = true;
          yaml.enable = true;
          zig.enable = false;
        };
        plugins = {
          enable = true;
          auto-session.enable = true;
          bufferline.enable = true;
          cmp.enable = true;
          comment.enable = true;
          format.enable = true;
          git.enable = true;
          indent-blankline.enable = true;
          lint.enable = true;
          lsp.enable = true;
          lualine.enable = true;
          lz-n.enable = true;
          nix.enable = true;
          noice.enable = true;
          smart-splits.enable = true;
          substitute.enable = true;
          supermaven.enable = true;
          surround.enable = true;
          telescope.enable = true;
          todo-comments.enable = true;
          treesitter.enable = true;
          trouble.enable = true;
          undotree.enable = true;
          which-key.enable = true;
          yazi.enable = true;
        };
      };
      oh-my-posh.enable = true;
      tmux.enable = true;
      yazi.enable = true;
      zsh = {
        enable = true;
        plugins = {
          enable = true;
          zsh-vi-mode.enable = true;
          zsh-autopair.enable = true;
          zsh-fzf-tab.enable = true;
          zsh-auto-notify.enable = false;
          zsh-autosuggestions-abbreviations-strategy.enable = true;
          zsh-system-clipboard.enable = false;
          zsh-zhooks.enable = true;
          zsh-abbr.enable = true;
        };
      };
      bat.enable = true;
      btop.enable = true;
      catppuccin.enable = true;
      fastfetch.enable = true;
      fzf.enable = true;
      git.enable = true;
      index.enable = true;
      shell.enable = true;
      tldr.enable = true;
    };
  };
}
