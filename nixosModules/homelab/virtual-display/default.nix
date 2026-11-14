{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  inherit (config.settings) username;
  cfg = homelab.virtual-display;
  user_cfg = config.home-manager.users.${username}.modules.ai.virtual-display;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
in {
  options.modules.homelab.virtual-display = {
    enable = lib.mkEnableOption "Expose the agent virtual desktop (noVNC) through nginx";
    name = lib.mkOption {
      type = lib.types.str;
      default = "virtual-display";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "de";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = user_cfg.enable && user_cfg.vnc.enable;
        message = "modules.homelab.virtual-display requires modules.ai.virtual-display.{enable,vnc.enable} in home-manager for ${username}.";
      }
    ];

    # Password protects the web client; the VNC server itself only listens on localhost.
    home-manager.users.${username}.modules.ai.virtual-display.vnc.passwordFile =
      config.clan.core.vars.generators.${cfg.name}.files.rfbauth.path;

    clan.core.vars.generators.${cfg.name} = {
      files = {
        # Shown to the user; the VNC protocol only uses the first 8 characters
        password = {};
        rfbauth.owner = username;
      };
      runtimeInputs = [
        pkgs.pwgen
        pkgs.x11vnc
      ];
      script = ''
        pwgen -s 8 1 | tr -d '\n' > "$out/password"
        x11vnc -storepasswd "$(cat "$out/password")" "$out/rfbauth"
      '';
    };

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations = {
        "= /".return = "302 /vnc.html?autoconnect=1&resize=scale";
        "/" = {
          proxyPass = "http://127.0.0.1:${toString user_cfg.vnc.webPort}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_read_timeout 1d;
            proxy_send_timeout 1d;
          '';
        };
      };
    };
  };
}
