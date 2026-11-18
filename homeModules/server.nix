{lib, ...}: {
  imports = [
    ./default.nix
  ];
  modules = {
    home = {
      enable = lib.mkDefault true;
      nix.enable = lib.mkDefault true;
      oh-my-posh.enable = lib.mkDefault true;
      tmux.enable = lib.mkDefault true;
      rex = {
        enable = lib.mkDefault true;
        server.enable = lib.mkDefault true;
      };
      yazi.enable = lib.mkDefault true;
      zsh = {
        enable = lib.mkDefault true;
        plugins = {
          enable = lib.mkDefault true;
          zsh-vi-mode.enable = lib.mkDefault true;
          zsh-autopair.enable = lib.mkDefault true;
          zsh-fzf-tab.enable = lib.mkDefault true;
          zsh-auto-notify.enable = lib.mkDefault false;
          zsh-autosuggestions-abbreviations-strategy.enable = lib.mkDefault true;
          zsh-system-clipboard.enable = lib.mkDefault false;
          zsh-zhooks.enable = lib.mkDefault true;
          zsh-abbr.enable = lib.mkDefault true;
        };
      };
      bat.enable = lib.mkDefault true;
      catppuccin.enable = lib.mkDefault true;
      fastfetch.enable = lib.mkDefault true;
      fzf.enable = lib.mkDefault true;
      git.enable = lib.mkDefault true;
      index.enable = lib.mkDefault true;
      shell.enable = lib.mkDefault true;
      tldr.enable = lib.mkDefault true;
    };
    ai = {
      enable = lib.mkDefault true;
      pi.enable = lib.mkDefault false;
      codex.enable = lib.mkDefault false;
      cursor.enable = lib.mkDefault false;
      grok.enable = lib.mkDefault false;
      claude.enable = lib.mkDefault true;
      t3-code.enable = lib.mkDefault false;
      workmux.enable = lib.mkDefault true;
    };
    dev = {
      enable = lib.mkDefault true;
      jujutsu.enable = lib.mkDefault false;
      lazygit.enable = lib.mkDefault true;
      nvim = {
        enable = lib.mkDefault true;
        languages = {
          enable = lib.mkDefault true;
          bash.enable = lib.mkDefault true;
          json.enable = lib.mkDefault true;
          c.enable = lib.mkDefault false;
          lua.enable = lib.mkDefault true;
          markdown.enable = lib.mkDefault true;
          nix.enable = lib.mkDefault true;
          python.enable = lib.mkDefault true;
          toml.enable = lib.mkDefault true;
          xml.enable = lib.mkDefault false;
          yaml.enable = lib.mkDefault true;
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
  };
}
