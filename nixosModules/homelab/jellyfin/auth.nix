{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.jellyfin;
  clientSecretPath = config.clan.core.vars.generators."${cfg.name}-oidc".files.client-secret.path;
  ssoConfig = "${cfg.dataDir}/plugins/configurations/SSO-Auth.xml";
in {
  options.modules.homelab.jellyfin.auth = {
    enable = lib.mkEnableOption "Enable jellyfin auth";
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) (lib.mkMerge [
    (outputs.lib.homelab.mkLocalOidcClient {
      inherit lib config pkgs;
      inherit (cfg) name;
      secretOwner = cfg.name;
      client = {
        client_id = "42VeHabCU9UyRptuVpwJlfd0wKqkpC0mddyY0qDihVhdyeox8wPxA4Tx9X0C30slzEAZOAPo";
        client_name = "Jellyfin";
        redirect_uris = ["https://${cfg.domainName}.${homelab.mainDomain}/sso/OID/redirect/authelia"];
        scopes = ["openid" "profile" "groups"];
        token_endpoint_auth_method = "client_secret_post";
      };
    })
    {
      # The SSO plugin keeps its provider settings, including account links, in its
      # own config file; only the client secret is kept in sync with the clan var.
      systemd.services.jellyfin.preStart = ''
        if [ -f '${ssoConfig}' ]; then
          ${lib.getExe pkgs.gnused} -i "s|<OidSecret>[^<]*</OidSecret>|<OidSecret>$(< ${clientSecretPath})</OidSecret>|" '${ssoConfig}'
        fi
      '';
    }
  ]);
}
