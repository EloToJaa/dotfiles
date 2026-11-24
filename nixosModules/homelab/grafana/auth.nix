{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.grafana;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  issuer = homelab.authelia.url;
  clientId = "Qm7xVr2NfLk9TdYw4HsA8eZpJc3UbGn6XoR5tKiW1vDyMhE0aSqCuPlFjBgZ7N2x";
  oidcGenerator = config.clan.core.vars.generators."${cfg.name}-oidc";
in {
  options.modules.homelab.grafana.auth = {
    enable = lib.mkEnableOption "Enable grafana single sign-on through authelia";
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) (lib.mkMerge [
    (outputs.lib.homelab.mkLocalOidcClient {
      inherit lib config pkgs;
      inherit (cfg) name;
      secretOwner = cfg.name;
      client = {
        client_id = clientId;
        client_name = "Grafana";
        redirect_uris = ["https://${domain}/login/generic_oauth"];
        scopes = ["openid" "profile" "email" "groups"];
      };
    })
    {
      services.grafana.settings = {
        auth.disable_login_form = false;
        "auth.generic_oauth" = {
          enabled = true;
          name = "Authelia";
          client_id = clientId;
          client_secret = "$__file{${oidcGenerator.files.client-secret.path}}";
          scopes = "openid profile email groups";
          auth_url = "${issuer}/api/oidc/authorization";
          token_url = "${issuer}/api/oidc/token";
          api_url = "${issuer}/api/oidc/userinfo";
          use_pkce = true;
          auto_login = false;
          allow_sign_up = true;
          login_attribute_path = "preferred_username";
          name_attribute_path = "name";
          groups_attribute_path = "groups";
          role_attribute_path = "contains(groups[*], 'grafana_admins') && 'GrafanaAdmin' || contains(groups[*], 'grafana_editors') && 'Editor' || contains(groups[*], 'grafana_viewers') && 'Viewer'";
          role_attribute_strict = true;
          allow_assign_grafana_admin = true;
        };
      };
    }
  ]);
}
