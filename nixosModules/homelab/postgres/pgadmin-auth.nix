{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.postgres.pgadmin;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  issuer = homelab.authelia.url;
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
  config = lib.mkIf (cfg.enable && cfg.auth.enable) (lib.mkMerge [
    (outputs.lib.homelab.mkLocalOidcClient {
      inherit lib config pkgs;
      inherit (cfg) name;
      secretOwner = "root";
      client = {
        client_id = clientId;
        client_name = "pgAdmin";
        authorization_policy = homelab.authelia.oidcAdminPolicy;
        redirect_uris = ["https://${domain}/oauth2/authorize"];
      };
    })
    {
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
    }
  ]);
}
