{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.settings) catppuccin atuin;
  shellAliases = {
    cd = "z";
  };
  cfg = config.modules.home.shell;
in {
  options.modules.home.shell = {
    enable = lib.mkEnableOption "Enable shell";
  };
  config = lib.mkIf cfg.enable {
    catppuccin = {
      atuin = {
        enable = true;
        inherit (catppuccin) flavor;
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
  };
}
