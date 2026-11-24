{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.karakeep;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  issuer = homelab.authelia.url;
  clientId = "JmOEKhsromX9mEQMmJReosFfa73tolCkpK4ITJfzTWkHvCplOx0h8PVo1hbfzSsG";
in {
  options.modules.homelab.karakeep.auth = {
    enable = lib.mkEnableOption "Enable karakeep single sign-on through authelia";
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) (lib.mkMerge [
    (outputs.lib.homelab.mkLocalOidcClient {
      inherit lib config pkgs;
      inherit (cfg) name;
      env = {
        var = "OAUTH_CLIENT_SECRET";
        owner = cfg.name;
      };
      client = {
        client_id = clientId;
        client_name = "Karakeep";
        require_pkce = false;
        pkce_challenge_method = "";
        claims_policy = cfg.name;
        redirect_uris = ["https://${domain}/api/auth/callback/custom"];
      };
    })
    {
      services.karakeep.extraEnvironment = {
        OAUTH_WELLKNOWN_URL = "${issuer}/.well-known/openid-configuration";
        OAUTH_CLIENT_ID = clientId;
        OAUTH_PROVIDER_NAME = "Authelia";
        OAUTH_SCOPE = "openid email profile";
        OAUTH_ALLOW_DANGEROUS_EMAIL_ACCOUNT_LINKING = "true";
      };

      systemd.services.karakeep-web.serviceConfig.EnvironmentFile = [
        config.clan.core.vars.generators."${cfg.name}-oidc-env".files.env.path
      ];

      # Karakeep reads the email from the ID token instead of the userinfo endpoint.
      services.authelia.instances.main.settings.identity_providers.oidc.claims_policies.${cfg.name}.id_token = ["email"];
    }
  ]);
}
