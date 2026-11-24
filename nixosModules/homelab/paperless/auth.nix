{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.paperless;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  issuer = "https://${homelab.authelia.domainName}.${homelab.baseDomain}";
  clientId = "AbSuaWOfsZfDjQFd6viSYt9g8TselL0RQVWNqMx4FYk19wjk0laCylGxR0UXn8uW";
  providerId = "authelia";
  oidcGenerator = config.clan.core.vars.generators."${cfg.name}-oidc";
  oidcEnvGenerator = config.clan.core.vars.generators."${cfg.name}-oidc-env";
in {
  options.modules.homelab.paperless.auth = {
    enable = lib.mkEnableOption "Enable paperless single sign-on through authelia";
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) {
    services.paperless.settings.PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";

    systemd.services.paperless-web.serviceConfig.EnvironmentFile = [
      oidcEnvGenerator.files.env.path
    ];

    services.authelia.instances.main.settings.identity_providers.oidc.clients = [
      {
        client_id = clientId;
        client_name = "Paperless";
        client_secret = "{{ secret \"${oidcGenerator.files.client-secret-hash.path}\" }}";
        public = false;
        authorization_policy = "two_factor";
        require_pkce = true;
        pkce_challenge_method = "S256";
        redirect_uris = [
          "https://${domain}/accounts/oidc/${providerId}/login/callback/"
        ];
        scopes = [
          "openid"
          "profile"
          "email"
          "groups"
        ];
        response_types = [
          "code"
        ];
        grant_types = [
          "authorization_code"
        ];
        access_token_signed_response_alg = "none";
        userinfo_signed_response_alg = "none";
        token_endpoint_auth_method = "client_secret_basic";
      }
    ];

    clan.core.vars.generators = {
      "${cfg.name}-oidc" = {
        runtimeInputs = [
          pkgs.pwgen
          pkgs.gnused
          pkgs.unstable.authelia
        ];
        files = {
          client-secret.deploy = false;
          client-secret-hash.owner = homelab.authelia.name;
        };
        script = ''
          pwgen -s 64 1 | tr -d '\n' > "$out/client-secret"
          authelia crypto hash generate pbkdf2 --no-confirm --password "$(cat "$out/client-secret")" \
            | sed 's/^Digest: //' | tr -d '\n' > "$out/client-secret-hash"
        '';
      };
      "${cfg.name}-oidc-env" = {
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
    };
  };
}
