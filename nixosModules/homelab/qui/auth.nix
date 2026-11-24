{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.qui;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  issuer = "https://${homelab.authelia.domainName}.${homelab.baseDomain}";
  clientId = "7PDzy1dcnsB2v6sZ3gXewTlUpthFJh3RhD8AMNPVBd7EZNpbGaKkWPhYZhCMCzO1";
  redirectUrl = "https://${domain}/api/auth/oidc/callback";
  oidcGenerator = config.clan.core.vars.generators."${cfg.name}-oidc";
in {
  options.modules.homelab.qui.auth = {
    enable = lib.mkEnableOption "Enable qui single sign-on through authelia";
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) {
    systemd.services.qui = {
      environment = {
        QUI__OIDC_ENABLED = "true";
        QUI__OIDC_ISSUER = issuer;
        QUI__OIDC_CLIENT_ID = clientId;
        QUI__OIDC_CLIENT_SECRET_FILE = "%d/oidcClientSecret";
        QUI__OIDC_REDIRECT_URL = redirectUrl;
      };
      serviceConfig.LoadCredential = lib.mkForce [
        "oidcClientSecret:${oidcGenerator.files.client-secret.path}"
      ];
    };

    services.authelia.instances.main.settings.identity_providers.oidc.clients = [
      {
        client_id = clientId;
        client_name = "qui";
        client_secret = "{{ secret \"${oidcGenerator.files.client-secret-hash.path}\" }}";
        public = false;
        authorization_policy = "two_factor";
        require_pkce = true;
        pkce_challenge_method = "S256";
        redirect_uris = [
          redirectUrl
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

    clan.core.vars.generators."${cfg.name}-oidc" = {
      runtimeInputs = [
        pkgs.pwgen
        pkgs.gnused
        pkgs.unstable.authelia
      ];
      files = {
        client-secret.owner = cfg.name;
        client-secret-hash.owner = homelab.authelia.name;
      };
      script = ''
        pwgen -s 64 1 | tr -d '\n' > "$out/client-secret"
        authelia crypto hash generate pbkdf2 --no-confirm --password "$(cat "$out/client-secret")" \
          | sed 's/^Digest: //' | tr -d '\n' > "$out/client-secret-hash"
      '';
    };
  };
}
