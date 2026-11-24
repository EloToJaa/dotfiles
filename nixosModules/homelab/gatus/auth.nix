{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.gatus;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  clientId = "9xm7d2BqXifJ7ChE57DOzEyVh6DsVJvTuJZFKiRjOFg4NFpxHNTBO3oQ5MzkpSk4";
in {
  options.modules.homelab.gatus.auth = {
    enable = lib.mkEnableOption "Enable gatus single sign-on through authelia";
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) (lib.mkMerge [
    (outputs.lib.homelab.mkLocalOidcClient {
      inherit lib config pkgs;
      inherit (cfg) name;
      env = {
        var = "GATUS_OIDC_CLIENT_SECRET";
        owner = "root";
      };
      client = {
        client_id = clientId;
        client_name = "Gatus";
        authorization_policy = homelab.authelia.oidcAdminPolicy;
        redirect_uris = ["https://${domain}/authorization-code/callback"];
        require_pkce = false;
        pkce_challenge_method = "";
      };
    })
    {
      services.gatus.settings.security.oidc = {
        issuer-url = homelab.authelia.url;
        redirect-url = "https://${domain}/authorization-code/callback";
        client-id = clientId;
        client-secret = "\${GATUS_OIDC_CLIENT_SECRET}";
        scopes = ["openid"];
      };

      systemd.services.gatus = {
        after = ["authelia-main.service"];
        wants = ["authelia-main.service"];
        serviceConfig.EnvironmentFile = [
          config.clan.core.vars.generators."${cfg.name}-oidc-env".files.env.path
        ];
      };
    }
  ]);
}
