{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.immich;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  issuer = "https://${homelab.authelia.domainName}.${homelab.baseDomain}";
  clientId = "hkBXBzttPNGdxwlmGfE5BOHUypTv5LTHt0nlRS5WQVeF2Ubj1HeIQaZpyPduVedP";
  oidcGenerator = config.clan.core.vars.generators."${cfg.name}-oidc";
  clientSecretPath = oidcGenerator.files.client-secret.path;
in {
  options.modules.homelab.immich.auth = {
    enable = lib.mkEnableOption "Enable immich single sign-on through authelia";
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) {
    containers.immich = {
      bindMounts.oidcSecret = {
        isReadOnly = true;
        hostPath = clientSecretPath;
        mountPoint = clientSecretPath;
      };
      config.services.immich.settings = {
        passwordLogin.enabled = true;
        oauth = {
          enabled = true;
          issuerUrl = issuer;
          inherit clientId;
          clientSecret._secret = clientSecretPath;
          scope = "openid profile email";
          tokenEndpointAuthMethod = "client_secret_basic";
          buttonText = "Login with Authelia";
          autoRegister = true;
          autoLaunch = false;
        };
      };
    };

    services.authelia.instances.main.settings.identity_providers.oidc.clients = [
      {
        client_id = clientId;
        client_name = "Immich";
        client_secret = "{{ secret \"${oidcGenerator.files.client-secret-hash.path}\" }}";
        public = false;
        authorization_policy = "two_factor";
        require_pkce = true;
        pkce_challenge_method = "S256";
        redirect_uris = [
          "https://${domain}/auth/login"
          "https://${domain}/user-settings"
          "app.immich:///oauth-callback"
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
