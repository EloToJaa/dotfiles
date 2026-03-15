{
  lib,
  config,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.vaultwarden;
in {
  options.modules.homelab.vaultwarden.auth = {
    enable = lib.mkEnableOption "Enable vaultwarden auth";
  };
  config = lib.mkIf cfg.auth.enable {
    services.vaultwarden.config = {
      ssoEnabled = true;
      ssoOnly = false;
      ssoAuthority = "https://auth.${homelab.baseDomain}";
      ssoScopes = "profile email offline_access vaultwarden";
      ssoPkce = true;
      ssoClientId = "vaultwarden";
      ssoRolesEnabled = true;
      ssoRolesDefaultToUser = true;
      ssoRolesTokenPath = "/vaultwarden_roles";
    };

    services.authelia.instances.main.settings = {
      definitions.user_attibutes.vaultwarden_roles.expression = ''
        "vaultwarden_admins" in groups ? ["admin"] : "vaultwarden_users" in groups ? ["user"] : [""]
      '';
      identity_providers.oidc = {
        claims_policies.vaultwarden = {
          id_token = ["vaultwarden_roles"];
          custom_claims.vaultwarden_roles = {};
        };
        scopes.vaultwarden.claims = [
          "vaultwarden_roles"
        ];
        clients = [
          {
            client_id = "vaultwarden";
            client_name = "Vaultwarden";
            client_secret = "{{ secret \"${config.sops.secrets."authelia/secrets/vaultwarden".path}\" }}";
            public = false;
            authorization_policy = "two_factor";
            require_pkce = true;
            pkce_challenge_method = "S256";
            claims_policy = "vaultwarden";
            redirect_uris = [
              "https://${cfg.domainName}.${homelab.mainDomain}/sso/OID/redirect/authelia"
            ];
            scopes = [
              "openid"
              "offline_access"
              "profile"
              "email"
              "vaultwarden"
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
    };
  };
}
