{
  lib,
  config,
  ...
}: let
  inherit (config.modules) homelab;
  inherit (config.settings) username;
  cfg = homelab.t3-code;
  user_cfg = config.home-manager.users.${username}.modules.ai.t3-code;
in {
  options.modules.homelab.t3-code = {
    enable = lib.mkEnableOption "Expose the T3 Code user service through nginx";
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "t3";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = user_cfg.service.port;
      defaultText = lib.literalExpression "home-manager.users.<username>.modules.ai.t3-code.service.port";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = user_cfg.enable && user_cfg.service.enable;
        message = "modules.homelab.t3-code requires modules.ai.t3-code.service.enable in home-manager for ${username}.";
      }
    ];

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
        # keep long-lived agent websocket sessions open; cookies are HTTPS-only
        extraConfig = ''
          proxy_read_timeout 1d;
          proxy_send_timeout 1d;
          proxy_cookie_flags ~ secure;
        '';
      };
    };
  };
}
