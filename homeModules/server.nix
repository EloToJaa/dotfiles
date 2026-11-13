{lib, ...}: {
  imports = [
    ./default.nix
  ];
  modules = {
    home = {
      enable = true;
      nix.enable = true;
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
      catppuccin.enable = true;
      fastfetch.enable = true;
      fzf.enable = true;
      git.enable = true;
      index.enable = true;
      shell.enable = true;
      tldr.enable = true;
    };
    ai = {
      enable = true;
      pi.enable = lib.mkDefault false;
      codex.enable = lib.mkDefault false;
      claude.enable = lib.mkDefault true;
      t3-code.enable = lib.mkDefault false;
      workmux.enable = lib.mkDefault true;
    };
    dev = {
      enable = lib.mkDefault true;
      jujutsu.enable = lib.mkDefault true;
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
