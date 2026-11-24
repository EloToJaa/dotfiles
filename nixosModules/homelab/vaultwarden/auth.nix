{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.vaultwarden;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  clientId = "U6q0xNiGN.y2KqGANMx5We30Pj2PtI1aUB_rSd9iDP0K19gmCNBNhGVk02eOOND.fH4Lg_w3";
  oidcGenerator = config.clan.core.vars.generators."${cfg.name}-oidc";
in {
  options.modules.homelab.vaultwarden.auth = {
    enable = lib.mkEnableOption "Enable vaultwarden single sign-on through authelia";
    group = lib.mkOption {
      type = lib.types.str;
      default = "vaultwarden_users";
      description = "LLDAP group whose members may sign in to Vaultwarden through Authelia";
    };
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) {
    services.vaultwarden.config = {
      ssoEnabled = true;
      ssoOnly = false;
      ssoAuthority = "https://${homelab.authelia.domainName}.${homelab.baseDomain}";
      ssoScopes = "openid email profile offline_access";
      ssoPkce = true;
      ssoClientId = clientId;
    };

    services.authelia.instances.main.settings.identity_providers.oidc = {
      authorization_policies.vaultwarden = {
        default_policy = "deny";
        rules = [
          {
            policy = "two_factor";
            subject = "group:${cfg.auth.group}";
          }
        ];
      };
      clients = [
        {
          client_id = clientId;
          client_name = "Vaultwarden";
          client_secret = "{{ secret \"${oidcGenerator.files.client-secret-hash.path}\" }}";
          public = false;
          authorization_policy = "vaultwarden";
          require_pkce = true;
          pkce_challenge_method = "S256";
          redirect_uris = [
            "https://${domain}/identity/connect/oidc-signin"
          ];
          scopes = [
            "openid"
            "offline_access"
            "profile"
            "email"
          ];
          response_types = [
            "code"
          ];
          grant_types = [
            "authorization_code"
            "refresh_token"
          ];
          access_token_signed_response_alg = "none";
          userinfo_signed_response_alg = "none";
          token_endpoint_auth_method = "client_secret_basic";
        }
      ];
    };

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
  };
}
