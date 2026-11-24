{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.radarr;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  issuer = "https://${homelab.authelia.domainName}.${homelab.baseDomain}";
  clientId = "arYY6TpVj0RYcfhpdC0zqbULh2o8xw47LvjQZEZqodcqR6I8tmnZvmB9Cbr3Epci";
  oidcGenerator = config.clan.core.vars.generators."${cfg.name}-oidc";
  envGenerator = config.clan.core.vars.generators."${cfg.name}-oidc-env";
in {
  options.modules.homelab.radarr.auth = {
    enable = lib.mkEnableOption "Enable radarr single sign-on through authelia";
    userIdentifier = lib.mkOption {
      type = lib.types.str;
      default = config.settings.email;
      description = "Verified email (or OIDC subject) of the only user allowed to sign in";
    };
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) {
    systemd.services.radarr = {
      environment = {
        RADARR__AUTH__METHOD = "Oidc";
        RADARR__AUTH__OIDCAUTHORITY = issuer;
        RADARR__AUTH__OIDCCLIENTID = clientId;
        RADARR__AUTH__OIDCUSERIDENTIFIER = cfg.auth.userIdentifier;
      };
      serviceConfig.EnvironmentFile = [envGenerator.files.env.path];
    };

    services.authelia.instances.main.settings.identity_providers.oidc.clients = [
      {
        client_id = clientId;
        client_name = "Radarr";
        client_secret = "{{ secret \"${oidcGenerator.files.client-secret-hash.path}\" }}";
        public = false;
        authorization_policy = homelab.authelia.oidcAdminPolicy;
        require_pkce = true;
        pkce_challenge_method = "S256";
        redirect_uris = [
          "https://${domain}/signin-oidc"
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
        token_endpoint_auth_method = "client_secret_post";
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
        files.env.owner = cfg.name;
        script = ''
          echo "RADARR__AUTH__OIDCCLIENTSECRET=$(cat "$in/${cfg.name}-oidc/client-secret")" > "$out/env"
        '';
      };
    };
  };
}
