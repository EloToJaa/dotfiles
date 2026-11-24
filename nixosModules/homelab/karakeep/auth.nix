{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.karakeep;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  issuer = "https://${homelab.authelia.domainName}.${homelab.baseDomain}";
  clientId = "JmOEKhsromX9mEQMmJReosFfa73tolCkpK4ITJfzTWkHvCplOx0h8PVo1hbfzSsG";
  oidcGenerator = config.clan.core.vars.generators."${cfg.name}-oidc";
  oidcEnvGenerator = config.clan.core.vars.generators."${cfg.name}-oidc-env";
in {
  options.modules.homelab.karakeep.auth = {
    enable = lib.mkEnableOption "Enable karakeep single sign-on through authelia";
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) {
    services.karakeep.extraEnvironment = {
      OAUTH_WELLKNOWN_URL = "${issuer}/.well-known/openid-configuration";
      OAUTH_CLIENT_ID = clientId;
      OAUTH_PROVIDER_NAME = "Authelia";
      OAUTH_SCOPE = "openid email profile";
      OAUTH_ALLOW_DANGEROUS_EMAIL_ACCOUNT_LINKING = "true";
    };

    systemd.services.karakeep-web.serviceConfig.EnvironmentFile = [
      oidcEnvGenerator.files.env.path
    ];

    services.authelia.instances.main.settings.identity_providers.oidc = {
      # Karakeep reads the email from the ID token instead of the userinfo endpoint.
      claims_policies.${cfg.name}.id_token = ["email"];
      clients = [
        {
          client_id = clientId;
          client_name = "Karakeep";
          client_secret = "{{ secret \"${oidcGenerator.files.client-secret-hash.path}\" }}";
          public = false;
          authorization_policy = "two_factor";
          require_pkce = false;
          pkce_challenge_method = "";
          claims_policy = cfg.name;
          redirect_uris = [
            "https://${domain}/api/auth/callback/custom"
          ];
          scopes = [
            "openid"
            "profile"
            "email"
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
    };

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
        files.env.owner = cfg.name;
        script = ''
          printf 'OAUTH_CLIENT_SECRET=%s\n' "$(cat "$in/${cfg.name}-oidc/client-secret")" > "$out/env"
        '';
      };
    };
  };
}
