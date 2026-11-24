{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.jellyfin;
  clientId = "42VeHabCU9UyRptuVpwJlfd0wKqkpC0mddyY0qDihVhdyeox8wPxA4Tx9X0C30slzEAZOAPo";
  clientSecretPath = config.clan.core.vars.generators."${cfg.name}-oidc".files.client-secret.path;
  ssoConfig = "${cfg.dataDir}/plugins/configurations/SSO-Auth.xml";
  provider = "/PluginConfiguration/OidConfigs/item[key/string='authelia']/value/PluginConfiguration";

  setValue = field: value: "-u ${lib.escapeShellArg "${provider}/${field}"} -v ${value}";
  setList = field: values:
    lib.concatStringsSep " " (
      ["-d ${lib.escapeShellArg "${provider}/${field}/string"}"]
      ++ map (value: "-s ${lib.escapeShellArg "${provider}/${field}"} -t elem -n string -v ${lib.escapeShellArg value}") values
    );
  edits = lib.concatStringsSep " " [
    (setValue "OidEndpoint" (lib.escapeShellArg homelab.authelia.url))
    (setValue "OidClientId" (lib.escapeShellArg clientId))
    (setValue "OidSecret" ''"$(< ${clientSecretPath})"'')
    (setValue "RoleClaim" "groups")
    (setValue "SchemeOverride" "https")
    (setList "Roles" cfg.auth.roles)
    (setList "AdminRoles" cfg.auth.adminRoles)
  ];
in {
  options.modules.homelab.jellyfin.auth = {
    enable = lib.mkEnableOption "Enable jellyfin auth";
    roles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["jellyfin-users" "jellyfin-admins"];
      description = "LLDAP groups whose members may sign in to Jellyfin through Authelia";
    };
    adminRoles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["jellyfin-admins"];
      description = "LLDAP groups whose members become Jellyfin administrators";
    };
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) (lib.mkMerge [
    (outputs.lib.homelab.mkLocalOidcClient {
      inherit lib config pkgs;
      inherit (cfg) name;
      secretOwner = cfg.name;
      client = {
        client_id = clientId;
        client_name = "Jellyfin";
        redirect_uris = ["https://${cfg.domainName}.${homelab.baseDomain}/sso/OID/redirect/authelia"];
        scopes = ["openid" "profile" "groups"];
        token_endpoint_auth_method = "client_secret_post";
      };
    })
    {
      # The SSO plugin keeps its account links (CanonicalLinks) and other runtime state
      # in its own config file, so only the Authelia provider settings are patched in.
      systemd.services.jellyfin.preStart = ''
        if [ -f '${ssoConfig}' ]; then
          ${lib.getExe pkgs.xmlstarlet} ed -L ${edits} '${ssoConfig}'
        fi
      '';
    }
  ]);
}
