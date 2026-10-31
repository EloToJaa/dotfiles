{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  cfg = config.modules.desktop.notifications;
in {
  options.modules.desktop.notifications = {
    enable = lib.mkEnableOption "Enable notifications";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.unstable.ntfy-sh
      pkgs.libnotify
    ];

    home.file.".config/ntfy/client.yml".source =
      config.lib.file.mkOutOfStoreSymlink osConfig.clan.core.vars.generators.ntfy-client.files."client.yml".path;
  };
}
