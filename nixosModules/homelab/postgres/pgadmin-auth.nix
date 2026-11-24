{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.postgres.pgadmin;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  issuer = "https://${homelab.authelia.domainName}.${homelab.baseDomain}";
  clientId = "j22zgFGXyvANoYyNl7d80YYAd8PDgju6OFl4D8TSDy3KQ0inumKdl0JPzIXDCRk3";
  oidcGenerator = config.clan.core.vars.generators."${cfg.name}-oidc";
  oauth2Config = {
    OAUTH2_NAME = "authelia";
    OAUTH2_DISPLAY_NAME = "Authelia";
    OAUTH2_CLIENT_ID = clientId;
    OAUTH2_API_BASE_URL = issuer;
    OAUTH2_AUTHORIZATION_URL = "${issuer}/api/oidc/authorization";
    OAUTH2_TOKEN_URL = "${issuer}/api/oidc/token";
    OAUTH2_USERINFO_ENDPOINT = "${issuer}/api/oidc/userinfo";
    OAUTH2_SERVER_METADATA_URL = "${issuer}/.well-known/openid-configuration";
    OAUTH2_SCOPE = "openid email profile";
    OAUTH2_USERNAME_CLAIM = "email";
    OAUTH2_ICON = "fa-openid";
    OAUTH2_CHALLENGE_METHOD = "S256";
    OAUTH2_RESPONSE_TYPE = "code";
  };
in {
  options.modules.homelab.postgres.pgadmin.auth = {
    enable = lib.mkEnableOption "Enable pgAdmin single sign-on through authelia";
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) {
    services.pgadmin.settings = {
      AUTHENTICATION_SOURCES = ["oauth2" "internal"];
      OAUTH2_AUTO_CREATE_USER = true;
    };

    environment.etc."pgadmin/config_system.py".text = lib.mkAfter ''
      import json
      import os
      with open(os.path.join(os.environ['CREDENTIALS_DIRECTORY'], 'oidc_client_secret')) as f:
        OAUTH2_CONFIG = [dict(json.loads(${builtins.toJSON (builtins.toJSON oauth2Config)}), OAUTH2_CLIENT_SECRET=f.read().strip())]
    '';

    systemd.services.pgadmin.serviceConfig.LoadCredential = [
      "oidc_client_secret:${oidcGenerator.files.client-secret.path}"
    ];

    services.authelia.instances.main.settings.identity_providers.oidc.clients = [
      {
        client_id = clientId;
        client_name = "pgAdmin";
        client_secret = "{{ secret \"${oidcGenerator.files.client-secret-hash.path}\" }}";
        public = false;
        authorization_policy = "two_factor";
        require_pkce = true;
        pkce_challenge_method = "S256";
        redirect_uris = [
          "https://${domain}/oauth2/authorize"
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
        client-secret = {};
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
