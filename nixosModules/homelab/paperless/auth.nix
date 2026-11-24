{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.paperless;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  issuer = homelab.authelia.url;
  clientId = "AbSuaWOfsZfDjQFd6viSYt9g8TselL0RQVWNqMx4FYk19wjk0laCylGxR0UXn8uW";
  providerId = "authelia";
in {
  options.modules.homelab.paperless.auth = {
    enable = lib.mkEnableOption "Enable paperless single sign-on through authelia";
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) (lib.mkMerge [
    (outputs.lib.homelab.mkLocalOidcClient {
      inherit lib config pkgs;
      inherit (cfg) name;
      client = {
        client_id = clientId;
        client_name = "Paperless";
        redirect_uris = ["https://${domain}/accounts/oidc/${providerId}/login/callback/"];
        scopes = ["openid" "profile" "email" "groups"];
      };
    })
    {
      services.paperless.settings.PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";

      systemd.services.paperless-web.serviceConfig.EnvironmentFile = [
        config.clan.core.vars.generators."${cfg.name}-oidc-env".files.env.path
      ];

      clan.core.vars.generators."${cfg.name}-oidc-env" = {
        dependencies = ["${cfg.name}-oidc"];
        runtimeInputs = [pkgs.jq];
        files.env.owner = cfg.name;
        script = ''
          providers=$(jq -cn --rawfile secret "$in/${cfg.name}-oidc/client-secret" '{
            openid_connect: {
              SCOPE: ["openid", "profile", "email"],
              OAUTH_PKCE_ENABLED: true,
              APPS: [{
                provider_id: "${providerId}",
                name: "Authelia",
                client_id: "${clientId}",
                secret: $secret,
                settings: {
                  server_url: "${issuer}",
                  token_auth_method: "client_secret_basic"
                }
              }]
            }
          }')
          printf "PAPERLESS_SOCIALACCOUNT_PROVIDERS='%s'\n" "$providers" > "$out/env"
        '';
      };
    }
  ]);
}
