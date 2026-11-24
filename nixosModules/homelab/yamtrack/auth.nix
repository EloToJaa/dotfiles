{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.yamtrack;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  issuer = "https://${homelab.authelia.domainName}.${homelab.baseDomain}";
  clientId = "ncoHLrQqBY0PdmH0yx6GnP7nkcNvoRKDZcyCNX0IFwVVmGKyaYqa1X6QxkfaD9Wl";
  providerId = "authelia";
  oidcGenerator = config.clan.core.vars.generators."${cfg.name}-oidc";
  providersGenerator = config.clan.core.vars.generators."${cfg.name}-oidc-providers";
  providers = {
    openid_connect.APPS = [
      {
        provider_id = providerId;
        name = "Authelia";
        client_id = clientId;
        settings = {
          server_url = issuer;
          token_auth_method = "client_secret_basic";
          oauth_pkce_enabled = true;
        };
      }
    ];
  };
in {
  options.modules.homelab.yamtrack.auth = {
    enable = lib.mkEnableOption "Enable Yamtrack single sign-on through authelia";
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) {
    systemd.services = lib.genAttrs ["yamtrack-migrate" "yamtrack" "yamtrack-worker" "yamtrack-beat"] (_: {
      environment = {
        SOCIAL_PROVIDERS = "allauth.socialaccount.providers.openid_connect";
        SOCIALACCOUNT_PROVIDERS_FILE = providersGenerator.files.providers.path;
      };
    });

    services.authelia.instances.main.settings.identity_providers.oidc.clients = [
      {
        client_id = clientId;
        client_name = "Yamtrack";
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
        client-secret.deploy = false;
        client-secret-hash.owner = homelab.authelia.name;
      };
      script = ''
        pwgen -s 64 1 | tr -d '\n' > "$out/client-secret"
        authelia crypto hash generate pbkdf2 --no-confirm --password "$(cat "$out/client-secret")" \
          | sed 's/^Digest: //' | tr -d '\n' > "$out/client-secret-hash"
      '';
    };

    # Yamtrack's secret loader reads every file in the secret's directory,
    # so the providers file lives in its own generator.
    clan.core.vars.generators."${cfg.name}-oidc-providers" = {
      dependencies = ["${cfg.name}-oidc"];
      runtimeInputs = [pkgs.jq];
      files.providers = {
        owner = cfg.name;
        group = cfg.name;
      };
      script = ''
        jq -c --rawfile secret "$in/${cfg.name}-oidc/client-secret" \
          '.openid_connect.APPS[0].secret = $secret' \
          ${pkgs.writeText "yamtrack-socialaccount-providers.json" (builtins.toJSON providers)} \
          > "$out/providers"
      '';
    };
  };
}
