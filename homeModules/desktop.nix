{lib, ...}: {
  imports = [
    ./default.nix
  ];
  modules = {
    cybersec = {
      enable = lib.mkDefault false;
    };
    desktop = {
      enable = lib.mkDefault true;
      umbriel.enable = lib.mkDefault true;
      rider.enable = lib.mkDefault false;
      satty.enable = lib.mkDefault true;
      wallpapers.enable = lib.mkDefault true;
      artcraft = {
        photocraft.enable = lib.mkDefault true;
        wordcraft.enable = lib.mkDefault true;
      };
      bluetooth.enable = lib.mkDefault true;
      cava.enable = lib.mkDefault true;
      chromium.enable = lib.mkDefault true;
      clipboard.enable = lib.mkDefault true;
      discord.enable = lib.mkDefault true;
      noctalia-shell.enable = lib.mkDefault true;
      ghostty.enable = lib.mkDefault true;
      gnome.enable = lib.mkDefault true;
      helium.enable = lib.mkDefault true;
      gtk = {
        enable = lib.mkDefault true;
        applyTheme = lib.mkDefault true;
      };
      luciole.enable = lib.mkDefault true;
      nautilus.enable = lib.mkDefault true;
      notifications.enable = lib.mkDefault true;
      omnissa-horizon.enable = lib.mkDefault true;
      piper-tts.enable = lib.mkDefault true;
      prismlauncher.enable = lib.mkDefault true;
      remmina.enable = lib.mkDefault true;
      spotify.enable = lib.mkDefault true;
      voxtype.enable = lib.mkDefault true;
      winboat.enable = lib.mkDefault true;
      xdg-mimes.enable = lib.mkDefault true;
      zen.enable = lib.mkDefault true;
    };
    ai = {
      enable = lib.mkDefault true;
      claude.enable = lib.mkDefault true;
      memory.enable = lib.mkDefault true;
      grafana.enable = lib.mkDefault true;
      truenas.enable = lib.mkDefault true;
      unifi.enable = lib.mkDefault true;
      ollama.enable = lib.mkDefault true;
      hermes-desktop.enable = lib.mkDefault false;
      grok-bot.enable = lib.mkDefault true;
      grok.enable = lib.mkDefault true;
      cursor.enable = lib.mkDefault true;
      t3-code = {
        enable = lib.mkDefault true;
        desktop.enable = lib.mkDefault true;
      };
      workmux.enable = lib.mkDefault true;
      crash.enable = lib.mkDefault true;
    };
    dev = {
      enable = lib.mkDefault true;
      aoc.enable = lib.mkDefault true;
      jujutsu.enable = lib.mkDefault false;
      lazygit.enable = lib.mkDefault true;
      rbw.enable = lib.mkDefault true;
      zed.enable = lib.mkDefault true;
      nvim = {
        enable = lib.mkDefault true;
        languages = {
          enable = lib.mkDefault true;
          bash.enable = lib.mkDefault true;
          c.enable = lib.mkDefault true;
          csharp.enable = lib.mkDefault true;
          go.enable = lib.mkDefault true;
          javascript.enable = lib.mkDefault true;
          json.enable = lib.mkDefault true;
          lua.enable = lib.mkDefault true;
          markdown.enable = lib.mkDefault true;
          nix.enable = lib.mkDefault true;
          python.enable = lib.mkDefault true;
          rust.enable = lib.mkDefault true;
          toml.enable = lib.mkDefault true;
          xml.enable = lib.mkDefault true;
          yaml.enable = lib.mkDefault true;
          zig.enable = lib.mkDefault true;
        };
        plugins = {
          enable = lib.mkDefault true;
          auto-session.enable = lib.mkDefault true;
          bufferline.enable = lib.mkDefault true;
          cmp.enable = lib.mkDefault true;
          comment.enable = lib.mkDefault true;
          format.enable = lib.mkDefault true;
          git.enable = lib.mkDefault true;
          indent-blankline.enable = lib.mkDefault true;
          lint.enable = lib.mkDefault true;
          lsp.enable = lib.mkDefault true;
          lualine.enable = lib.mkDefault true;
          lz-n.enable = lib.mkDefault true;
          nix.enable = lib.mkDefault true;
          noice.enable = lib.mkDefault true;
          opencode.enable = lib.mkDefault false;
          smart-splits.enable = lib.mkDefault true;
          substitute.enable = lib.mkDefault true;
          supermaven.enable = lib.mkDefault true;
          surround.enable = lib.mkDefault true;
          telescope.enable = lib.mkDefault true;
          todo-comments.enable = lib.mkDefault true;
          treesitter.enable = lib.mkDefault true;
          trouble.enable = lib.mkDefault true;
          undotree.enable = lib.mkDefault true;
          which-key.enable = lib.mkDefault true;
          yazi.enable = lib.mkDefault true;
        };
      };
    };
    home = {
      enable = lib.mkDefault true;
      nix.enable = lib.mkDefault true;
      oh-my-posh.enable = lib.mkDefault true;
      tmux.enable = lib.mkDefault true;
      rex = {
        enable = lib.mkDefault true;
        server.enable = lib.mkDefault true;
        client.enable = lib.mkDefault true;
      };
      yazi.enable = lib.mkDefault true;
      zsh = {
        enable = lib.mkDefault true;
        plugins = {
          enable = lib.mkDefault true;
          zsh-vi-mode.enable = lib.mkDefault true;
          zsh-autopair.enable = lib.mkDefault true;
          zsh-fzf-tab.enable = lib.mkDefault true;
          zsh-auto-notify.enable = lib.mkDefault true;
          zsh-autosuggestions-abbreviations-strategy.enable = lib.mkDefault true;
          zsh-system-clipboard.enable = lib.mkDefault true;
          zsh-zhooks.enable = lib.mkDefault true;
          zsh-abbr.enable = lib.mkDefault true;
        };
      };
      accounts.enable = lib.mkDefault true;
      bat.enable = lib.mkDefault true;
      catppuccin.enable = lib.mkDefault true;
      fastfetch.enable = lib.mkDefault true;
      fzf.enable = lib.mkDefault true;
      git.enable = lib.mkDefault true;
      index.enable = lib.mkDefault true;
      shell.enable = lib.mkDefault true;
      tldr.enable = lib.mkDefault true;
    };
  };
}
