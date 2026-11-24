{
  lib,
  config,
  pkgs,
  outputs,
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
  config = lib.mkIf (cfg.enable && cfg.auth.enable) (lib.mkMerge [
    (outputs.lib.homelab.mkLocalOidcClient {
      inherit lib config pkgs;
      inherit (cfg) name;
      secretOwner = cfg.name;
      client = {
        client_id = clientId;
        client_name = "qui";
        authorization_policy = homelab.authelia.oidcAdminPolicy;
        redirect_uris = [redirectUrl];
      };
    })
    {
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
    }
  ]);
}
