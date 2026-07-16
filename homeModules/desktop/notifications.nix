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

    sops.secrets = {
      "ntfy-sh/password" = {};
    };
    sops.templates."ntfy-client.yml" = {
      content =
        /*
        yaml
        */
        ''
          default-host: ${ntfy}
          default-user: ${username}
          default-password: "${config.sops.placeholder."ntfy-sh/password"}"

          subscribe:
            - topic: elotoja
              command: notify-send "Important" "$m"
        '';
      path = "${config.home.homeDirectory}/.config/ntfy/client.yml";
    };
  };
}
