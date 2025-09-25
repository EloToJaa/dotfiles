{
  variables,
  pkgs,
  ...
}: let
  inherit (variables) atuin;
  shellAliases = {
    cd = "z";
  };
in {
  catppuccin = {
    atuin = {
      enable = true;
      inherit (variables.catppuccin) flavor;
    };
  };
  programs = {
    zsh.shellAliases = shellAliases;
    atuin = {
      enable = true;
      package = pkgs.unstable.atuin;

      enableZshIntegration = true;

      settings = {
        auto_sync = true;
        sync_frequency = "10m";
        sync_address = atuin;
        show_preview = true;
        store_failed = true;
        secrets_filter = true;
        enter_accept = true;
        keymap_mode = "vim-normal";
      };
    };
    zoxide = {
      enable = true;
      package = pkgs.unstable.zoxide;

      enableZshIntegration = true;
    };
    eza = {
      enable = true;
      package = pkgs.unstable.eza;

      enableZshIntegration = true;

      git = true;
      icons = "auto";
    };
    carapace = {
      enable = true;
      package = pkgs.unstable.carapace;

      enableZshIntegration = true;
    };
  };
}
