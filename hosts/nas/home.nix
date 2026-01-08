{
  imports = [
    ./../../homeModules
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
      btop.enable = true;
      catppuccin.enable = true;
      fastfetch.enable = true;
      fzf.enable = true;
      git.enable = true;
      index.enable = true;
      shell.enable = true;
      tldr.enable = true;
    };
    dev = {
      enable = true;
      lazygit.enable = true;
      nvim = {
        enable = true;
        languages = {
          enable = true;
          bash.enable = true;
          json.enable = true;
          lua.enable = true;
          markdown.enable = true;
          nix.enable = true;
          python.enable = true;
          toml.enable = true;
          xml.enable = true;
          yaml.enable = true;
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
    };
  };
}
