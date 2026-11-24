{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.immich;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  issuer = homelab.authelia.url;
  clientId = "hkBXBzttPNGdxwlmGfE5BOHUypTv5LTHt0nlRS5WQVeF2Ubj1HeIQaZpyPduVedP";
  clientSecretPath = config.clan.core.vars.generators."${cfg.name}-oidc".files.client-secret.path;
in {
  options.modules.homelab.immich.auth = {
    enable = lib.mkEnableOption "Enable immich single sign-on through authelia";
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) (lib.mkMerge [
    (outputs.lib.homelab.mkLocalOidcClient {
      inherit lib config pkgs;
      inherit (cfg) name;
      secretOwner = "root";
      client = {
        client_id = clientId;
        client_name = "Immich";
        redirect_uris = [
          "https://${domain}/auth/login"
          "https://${domain}/user-settings"
          "app.immich:///oauth-callback"
        ];
      };
    })
    {
      containers.immich = {
        bindMounts.oidcSecret = {
          isReadOnly = true;
          hostPath = clientSecretPath;
          mountPoint = clientSecretPath;
        };
        config.services.immich.settings = {
          passwordLogin.enabled = true;
          oauth = {
            enabled = true;
            issuerUrl = issuer;
            inherit clientId;
            clientSecret._secret = clientSecretPath;
            scope = "openid profile email";
            tokenEndpointAuthMethod = "client_secret_basic";
            buttonText = "Login with Authelia";
            autoRegister = true;
            autoLaunch = false;
          };
        };
      };
    }
  ]);
}
