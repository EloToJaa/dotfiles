{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.modules.desktop.noctalia-shell;
  noctaliaPackage = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  options.modules.desktop.noctalia-shell = {
    enable = lib.mkEnableOption "Enable Noctalia shell";
  };
  config = lib.mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      package = noctaliaPackage;
      systemd.enable = true;

      settings = {
        shell = {
          font_family = "JetBrainsMonoNL Nerd Font";
          telemetry_enabled = false;
          clipboard_enabled = true;
          clipboard_history_max_entries = 25;
        };
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Catppuccin";
        };
        bar.main.position = "bottom";
      };
    };
  };
}
