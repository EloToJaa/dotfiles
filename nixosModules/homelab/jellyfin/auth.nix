{
  lib,
  config,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.jellyfin.auth;
in {
  options.modules.homelab.jellyfin.auth = {
    enable = lib.mkEnableOption "Enable jellyfin auth";
  };
  config = lib.mkIf cfg.enable {
    services.authelia.instances.main.settings.identity_providers.oidc.clients = [
      {
        client_id = "jellyfin";
        client_name = "Jellyfin";
        client_secret = "{{ secret \"${config.sops.secrets."authelia/secrets/jellyfin".path}\" }}";
        public = false;
        authorization_policy = "two_factor";
        require_pkce = true;
        pkce_challenge_method = "S256";
        redirect_uris = [
          "https://${cfg.domainName}.${homelab.mainDomain}/sso/OID/redirect/authelia"
        ];
        scopes = [
          "openid"
          "profile"
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
        token_endpoint_auth_method = "client_secret_post";
      }
    ];

    sops.secrets = {
      "authelia/secrets/jellyfin" = {
        owner = "authelia";
      };
    };
  };
}
