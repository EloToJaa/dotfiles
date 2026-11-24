{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.radarr;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  issuer = homelab.authelia.url;
  clientId = "arYY6TpVj0RYcfhpdC0zqbULh2o8xw47LvjQZEZqodcqR6I8tmnZvmB9Cbr3Epci";
in {
  options.modules.homelab.radarr.auth = {
    enable = lib.mkEnableOption "Enable radarr single sign-on through authelia";
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
        var = "RADARR__AUTH__OIDCCLIENTSECRET";
        owner = cfg.name;
      };
      client = {
        client_id = clientId;
        client_name = "Radarr";
        authorization_policy = homelab.authelia.oidcAdminPolicy;
        redirect_uris = ["https://${domain}/signin-oidc"];
        token_endpoint_auth_method = "client_secret_post";
      };
    })
    {
      systemd.services.radarr = {
        environment = {
          RADARR__AUTH__METHOD = "Oidc";
          RADARR__AUTH__OIDCAUTHORITY = issuer;
          RADARR__AUTH__OIDCCLIENTID = clientId;
          RADARR__AUTH__OIDCUSERIDENTIFIER = cfg.auth.userIdentifier;
        };
        serviceConfig.EnvironmentFile = [
          config.clan.core.vars.generators."${cfg.name}-oidc-env".files.env.path
        ];
      };
    }
  ]);
}
