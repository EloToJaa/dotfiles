{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.vaultwarden;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  clientId = "U6q0xNiGN.y2KqGANMx5We30Pj2PtI1aUB_rSd9iDP0K19gmCNBNhGVk02eOOND.fH4Lg_w3";
in {
  options.modules.homelab.vaultwarden.auth = {
    enable = lib.mkEnableOption "Enable vaultwarden single sign-on through authelia";
    group = lib.mkOption {
      type = lib.types.str;
      default = "vaultwarden_users";
      description = "LLDAP group whose members may sign in to Vaultwarden through Authelia";
    };
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) (lib.mkMerge [
    (outputs.lib.homelab.mkLocalOidcClient {
      inherit lib config pkgs;
      inherit (cfg) name;
      client = {
        client_id = clientId;
        client_name = "Vaultwarden";
        authorization_policy = "vaultwarden";
        redirect_uris = ["https://${domain}/identity/connect/oidc-signin"];
        scopes = ["openid" "offline_access" "profile" "email"];
        grant_types = ["authorization_code" "refresh_token"];
      };
    })
    {
      services.vaultwarden.config = {
        ssoEnabled = true;
        ssoOnly = false;
        ssoAuthority = "https://${homelab.authelia.domainName}.${homelab.baseDomain}";
        ssoScopes = "openid email profile offline_access";
        ssoPkce = true;
        ssoClientId = clientId;
      };

      services.authelia.instances.main.settings.identity_providers.oidc.authorization_policies.vaultwarden = {
        default_policy = "deny";
        rules = [
          {
            policy = "two_factor";
            subject = "group:${cfg.auth.group}";
          }
        ];
      };
    }
  ]);
}
