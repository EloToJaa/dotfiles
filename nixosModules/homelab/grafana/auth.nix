{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.grafana;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  issuer = "https://${homelab.authelia.domainName}.${homelab.baseDomain}";
  clientId = "Qm7xVr2NfLk9TdYw4HsA8eZpJc3UbGn6XoR5tKiW1vDyMhE0aSqCuPlFjBgZ7N2x";
  oidcGenerator = config.clan.core.vars.generators."${cfg.name}-oidc";
in {
  options.modules.homelab.grafana.auth = {
    enable = lib.mkEnableOption "Enable grafana single sign-on through authelia";
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) {
    services.grafana.settings = {
      auth.disable_login_form = false;
      "auth.generic_oauth" = {
        enabled = true;
        name = "Authelia";
        client_id = clientId;
        client_secret = "$__file{${oidcGenerator.files.client-secret.path}}";
        scopes = "openid profile email groups";
        auth_url = "${issuer}/api/oidc/authorization";
        token_url = "${issuer}/api/oidc/token";
        api_url = "${issuer}/api/oidc/userinfo";
        use_pkce = true;
        auto_login = false;
        allow_sign_up = true;
        login_attribute_path = "preferred_username";
        name_attribute_path = "name";
        groups_attribute_path = "groups";
        role_attribute_path = "contains(groups[*], 'grafana_admins') && 'GrafanaAdmin' || contains(groups[*], 'grafana_editors') && 'Editor' || contains(groups[*], 'grafana_viewers') && 'Viewer'";
        role_attribute_strict = true;
        allow_assign_grafana_admin = true;
      };
    };

    services.authelia.instances.main.settings.identity_providers.oidc.clients = [
      {
        client_id = clientId;
        client_name = "Grafana";
        client_secret = "{{ secret \"${oidcGenerator.files.client-secret-hash.path}\" }}";
        public = false;
        authorization_policy = "two_factor";
        require_pkce = true;
        pkce_challenge_method = "S256";
        redirect_uris = [
          "https://${domain}/login/generic_oauth"
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

    clan.core.vars.generators."${cfg.name}-oidc" = {
      runtimeInputs = [
        pkgs.pwgen
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
