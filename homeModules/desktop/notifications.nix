{
  pkgs,
  lib,
  config,
  settings,
  ...
}: let
  cfg = config.modules.desktop.notifications;
  inherit (settings) username ntfy;
in {
  options.modules.desktop.notifications = {
    enable = lib.mkEnableOption "Enable notifications";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      ntfy-sh
      libnotify
    ];

    xdg.configFile."ntfy/client.yml".text =
      /*
      yaml
      */
      ''
        default-host: ${ntfy}
        default-user: ${username}

        subscribe:
          - topic: elotoja
            command: notify-send "Important" "$m"
      '';
  };
}
