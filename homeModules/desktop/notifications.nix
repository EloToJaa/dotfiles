{
  pkgs,
  lib,
  config,
  settings,
  ...
}: let
  cfg = config.modules.desktop.notifications;
  yaml = pkgs.formats.yaml {};
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
      content = builtins.readFile (yaml.generate "ntfy-client.yml" {
        "default-host" = ntfy;
        "default-user" = username;
        "default-password" = config.sops.placeholder."ntfy-sh/password";
        subscribe = [
          {
            topic = "elotoja";
            command = ''notify-send "Important" "$message"'';
          }
          {
            topic = "uptime";
            command = ''notify-send "$topic" "$message"'';
          }
        ];
      });
      path = "${config.home.homeDirectory}/.config/ntfy/client.yml";
    };
  };
}
