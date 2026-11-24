{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.sonarr;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  issuer = homelab.authelia.url;
  clientId = "AxngSlpHeuHpp3rPwbS2VksnVpz2i8NjxpLLKbBNtgwhKfCimoXMoD8grgiv34jO";
in {
  options.modules.homelab.sonarr.auth = {
    enable = lib.mkEnableOption "Enable sonarr single sign-on through authelia";
    userIdentifier = lib.mkOption {
      type = lib.types.str;
      default = config.settings.email;
      description = "Verified email (or OIDC subject) of the only user allowed to sign in";
    };
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) (lib.mkMerge [
    (outputs.lib.homelab.mkLocalOidcClient {
      inherit lib config pkgs;
      inherit (cfg) name;
      env = {
        var = "SONARR__AUTH__OIDCCLIENTSECRET";
        owner = cfg.name;
      };
      client = {
        client_id = clientId;
        client_name = "Sonarr";
        authorization_policy = homelab.authelia.oidcAdminPolicy;
        redirect_uris = ["https://${domain}/signin-oidc"];
        token_endpoint_auth_method = "client_secret_post";
      };
    })
    {
      systemd.services.sonarr = {
        environment = {
          SONARR__AUTH__METHOD = "Oidc";
          SONARR__AUTH__OIDCAUTHORITY = issuer;
          SONARR__AUTH__OIDCCLIENTID = clientId;
          SONARR__AUTH__OIDCUSERIDENTIFIER = cfg.auth.userIdentifier;
        };
        serviceConfig.EnvironmentFile = [
          config.clan.core.vars.generators."${cfg.name}-oidc-env".files.env.path
        ];
      };
    }
  ]);
}
